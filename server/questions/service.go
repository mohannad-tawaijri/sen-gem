package questions

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"gorm.io/gorm"
)

type Question struct {
	ID         string   `json:"id"`
	Difficulty int      `json:"difficulty"`
	Q          string   `json:"q"`
	Tags       []string `json:"tags"`
}

type Service struct {
	all       []Question
	db        *gorm.DB
	idAliases map[string]string
}

// canonical category slugs used by the frontend
var canonicalCategories = map[string]struct{}{
	"flags":           {},
	"got":             {},
	"onepiece":        {},
	"proverbs":        {},
	"football":        {},
	"premierleague":   {},
	"general":         {},
	"noWords":         {},
	"pictures":        {},
	"championsleague": {},
	"islamic":         {},
	"whoami":          {}, // Added missing category so backend recognizes "من أنا"
	"aot":             {},
}

// aliases from data tag -> canonical UI slug
var categoryAliases = map[string]string{
	"ucl": "championsleague",
}

// map lowercase slug to canonical casing used by UI
var canonByLower = map[string]string{
	"flags":           "flags",
	"got":             "got",
	"onepiece":        "onepiece",
	"proverbs":        "proverbs",
	"football":        "football",
	"premierleague":   "premierleague",
	"general":         "general",
	"nowords":         "noWords",
	"pictures":        "pictures",
	"championsleague": "championsleague",
	"islamic":         "islamic",
	"whoami":          "whoami",
	"aot":             "aot",
}

func canonicalizeSlug(name string) string {
	if v, ok := canonByLower[strings.ToLower(name)]; ok {
		return v
	}
	return name
}

func sliceContains(ss []string, s string) bool {
	for _, v := range ss {
		if v == s {
			return true
		}
	}
	return false
}

func NewService(dir string, db *gorm.DB) (*Service, error) {
	qs, aliases, err := loadFromDir(dir)
	if err != nil {
		return nil, err
	}
	// merge aliases from optional id_aliases.json produced by data normalization
	aliasFile := filepath.Join(dir, "id_aliases.json")
	if b, err := os.ReadFile(aliasFile); err == nil {
		// Strip BOM
		if len(b) >= 3 && b[0] == 0xEF && b[1] == 0xBB && b[2] == 0xBF {
			b = b[3:]
		}
		m := map[string]string{}
		if json.Unmarshal(b, &m) == nil {
			if aliases == nil {
				aliases = make(map[string]string)
			}
			for k, v := range m {
				aliases[k] = v
			}
		}
	}
	return &Service{all: qs, db: db, idAliases: aliases}, nil
}

// All returns the loaded questions list (read-only copy)
func (s *Service) All() []Question {
	out := make([]Question, len(s.all))
	copy(out, s.all)
	return out
}

// FindByID returns the question by its ID if it exists
func (s *Service) FindByID(id string) *Question {
	if s != nil && s.idAliases != nil {
		if can, ok := s.idAliases[id]; ok {
			id = can
		}
	}
	for i := range s.all {
		if s.all[i].ID == id {
			return &s.all[i]
		}
	}
	return nil
}

func loadFromDir(dir string) ([]Question, map[string]string, error) {
	var out []Question
	aliases := make(map[string]string)

	used := make(map[string]map[int]map[int]struct{}) // slug->diff->serial
	nextSerial := make(map[string]map[int]int)        // slug->diff->next
	ensureMaps := func(slug string, diff int) {
		if _, ok := used[slug]; !ok {
			used[slug] = make(map[int]map[int]struct{})
		}
		if _, ok := used[slug][diff]; !ok {
			used[slug][diff] = make(map[int]struct{})
		}
		if _, ok := nextSerial[slug]; !ok {
			nextSerial[slug] = make(map[int]int)
		}
		if _, ok := nextSerial[slug][diff]; !ok {
			nextSerial[slug][diff] = 1
		}
	}
	normalizeID := func(orig string, slug string, diff int) string {
		ensureMaps(slug, diff)
		serial := 0
		parts := strings.Split(orig, "-")
		if len(parts) >= 3 {
			if n, err := strconv.Atoi(parts[len(parts)-1]); err == nil {
				serial = n
			}
		}
		if serial <= 0 {
			serial = nextSerial[slug][diff]
		}
		for {
			if _, exists := used[slug][diff][serial]; !exists {
				break
			}
			serial++
		}
		used[slug][diff][serial] = struct{}{}
		if serial >= nextSerial[slug][diff] {
			nextSerial[slug][diff] = serial + 1
		}
		canonical := fmt.Sprintf("%s-%d-%03d", slug, diff, serial)
		if canonical != orig {
			aliases[orig] = canonical
		}
		return canonical
	}

	err := filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() {
			return nil
		}
		if !strings.HasSuffix(info.Name(), ".json") {
			return nil
		}
		// Only load files that correspond to known category slugs (or their aliases)
		// This avoids accidentally ingesting helper files like *_no_answers.json
		base := strings.TrimSuffix(info.Name(), filepath.Ext(info.Name()))
		slugCheck := canonicalizeSlug(base)
		allowed := false
		if _, ok := canonicalCategories[slugCheck]; ok {
			// allow exact canonical file, or alias file that maps to this canonical
			if base == slugCheck {
				allowed = true
			} else if canon, ok := categoryAliases[base]; ok && canon == slugCheck {
				allowed = true
			}
		}
		if !allowed {
			return nil
		}
		b, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		// Strip UTF-8 BOM if present
		if len(b) >= 3 && b[0] == 0xEF && b[1] == 0xBB && b[2] == 0xBF {
			b = b[3:]
		}
		var arr []Question
		if err := json.Unmarshal(b, &arr); err != nil {
			// ignore files that are not arrays of questions
			return nil
		}
		// ensure each question has the file's category slug as a tag
		// base and slug were computed earlier for allowed files
		slug := slugCheck
		filtered := make([]Question, 0, len(arr))
		for i := range arr {
			// ignore malformed entries (e.g., categories.json etc.)
			if strings.TrimSpace(arr[i].ID) == "" || arr[i].Difficulty == 0 {
				continue
			}
			if !sliceContains(arr[i].Tags, slug) {
				arr[i].Tags = append(arr[i].Tags, slug)
			}
			// normalize ID to <slug>-<difficulty>-NNN
			arr[i].ID = normalizeID(arr[i].ID, slug, arr[i].Difficulty)
			filtered = append(filtered, arr[i])
		}
		out = append(out, filtered...)
		return nil
	})
	return out, aliases, err
}

type Filter struct {
	Category   string
	Difficulty int
}

func (s *Service) NextForUser(userID uint, f Filter) (*Question, error) {
	// build candidate set
	candidates := make([]Question, 0, len(s.all))
	for _, q := range s.all {
		if f.Difficulty != 0 && q.Difficulty != f.Difficulty {
			continue
		}
		if f.Category != "" && !MatchesCategory(q.Tags, f.Category) {
			continue
		}
		candidates = append(candidates, q)
	}
	if len(candidates) == 0 {
		return nil, nil
	}

	// attempt random selection of unseen
	// We'll try up to N times before giving up
	tries := len(candidates)
	if tries > 50 {
		tries = 50
	}
	for i := 0; i < tries; i++ {
		idx := rand.Intn(len(candidates))
		cq := candidates[idx]
		unseen, err := s.tryMarkSeen(userID, cq)
		if err != nil {
			return nil, err
		}
		if unseen {
			return &cq, nil
		}
	}
	// fallback: linear scan
	for _, cq := range candidates {
		unseen, err := s.tryMarkSeen(userID, cq)
		if err != nil {
			return nil, err
		}
		if unseen {
			return &cq, nil
		}
	}
	return nil, nil // no unseen left
}

func (s *Service) tryMarkSeen(userID uint, q Question) (bool, error) {
	type QS struct {
		ID         uint   `gorm:"primaryKey"`
		UserID     uint   `gorm:"index"`
		QuestionID string `gorm:"index"`
		Category   string `gorm:"index"`
		Difficulty int    `gorm:"index"`
	}
	// attempt insert if not exists
	returnErr := s.db.Transaction(func(tx *gorm.DB) error {
		// check exists
		var count int64
		if err := tx.Table("question_seens").Where("user_id = ? AND question_id = ?", userID, q.ID).Count(&count).Error; err != nil {
			return err
		}
		// also check legacy aliases
		if count == 0 && s.idAliases != nil {
			for legacy, can := range s.idAliases {
				if can == q.ID {
					if err := tx.Table("question_seens").Where("user_id = ? AND question_id = ?", userID, legacy).Count(&count).Error; err != nil {
						return err
					}
					if count > 0 {
						break
					}
				}
			}
		}
		if count > 0 {
			return fmt.Errorf("seen")
		}
		// insert
		rec := map[string]any{
			"user_id":     userID,
			"question_id": q.ID,
			"category":    tagCategory(q.Tags),
			"difficulty":  q.Difficulty,
		}
		if err := tx.Table("question_seens").Create(rec).Error; err != nil {
			return err
		}
		return nil
	})
	if returnErr != nil {
		if returnErr.Error() == "seen" {
			return false, nil
		}
		return false, returnErr
	}
	return true, nil
}

// PreviewForUser returns up to 'limit' candidate questions for a user without marking them seen
func (s *Service) PreviewForUser(userID uint, f Filter, limit int) ([]Question, error) {
	// build candidate set
	candidates := make([]Question, 0, len(s.all))
	for _, q := range s.all {
		if f.Difficulty != 0 && q.Difficulty != f.Difficulty {
			continue
		}
		if f.Category != "" && !MatchesCategory(q.Tags, f.Category) {
			continue
		}
		candidates = append(candidates, q)
	}
	if len(candidates) == 0 || limit <= 0 {
		return []Question{}, nil
	}
	// fetch seen IDs for user under filter
	seenSet, err := s.getSeenSet(userID, f)
	if err != nil {
		return nil, err
	}
	pool := make([]Question, 0, len(candidates))
	for _, q := range candidates {
		if _, ok := seenSet[q.ID]; !ok {
			pool = append(pool, q)
		}
	}
	if len(pool) == 0 {
		return []Question{}, nil
	}
	// shuffle and take up to limit
	rand.Shuffle(len(pool), func(i, j int) { pool[i], pool[j] = pool[j], pool[i] })
	if limit > len(pool) {
		limit = len(pool)
	}
	out := make([]Question, limit)
	copy(out, pool[:limit])
	return out, nil
}

func (s *Service) getSeenSet(userID uint, f Filter) (map[string]struct{}, error) {
	rows := []struct{ QuestionID string }{}
	q := s.db.Table("question_seens").Select("question_id").Where("user_id = ?", userID)
	if f.Difficulty != 0 {
		q = q.Where("difficulty = ?", f.Difficulty)
	}
	if f.Category != "" {
		q = q.Where("category = ?", f.Category)
	}
	if err := q.Find(&rows).Error; err != nil {
		return nil, err
	}
	m := make(map[string]struct{}, len(rows))
	for _, r := range rows {
		id := r.QuestionID
		m[id] = struct{}{}
		if s.idAliases != nil {
			if can, ok := s.idAliases[id]; ok {
				m[can] = struct{}{}
			}
		}
	}
	return m, nil
}

func tagCategory(tags []string) string {
	// prefer canonical categories with alias support
	for _, t := range tags {
		if canon, ok := categoryAliases[t]; ok {
			return canon
		}
		if _, ok := canonicalCategories[t]; ok {
			return t
		}
	}
	if len(tags) > 0 {
		// fallback to first tag
		return tags[0]
	}
	return ""
}

func (s *Service) ResetUser(userID uint, f Filter) error {
	q := s.db.Table("question_seens").Where("user_id = ?", userID)
	if f.Difficulty != 0 {
		q = q.Where("difficulty = ?", f.Difficulty)
	}
	if f.Category != "" {
		q = q.Where("category = ?", f.Category)
	}
	return q.Delete(nil).Error
}

// MarkSeenByID marks a specific question id as seen for a user; returns true if newly marked
func (s *Service) MarkSeenByID(userID uint, qid string) (bool, error) {
	if s != nil && s.idAliases != nil {
		if can, ok := s.idAliases[qid]; ok {
			qid = can
		}
	}
	q := s.FindByID(qid)
	if q == nil {
		return false, fmt.Errorf("question not found")
	}
	return s.tryMarkSeen(userID, *q)
}

// MatchesCategory checks if the question belongs to the requested category
// It only matches against canonical category tags, not other descriptive tags
func MatchesCategory(tags []string, requested string) bool {
	req := requested
	// Check if requested category is in the canonical list
	if _, ok := canonicalCategories[req]; !ok {
		// If not canonical, check if it's an alias
		if canon, ok := categoryAliases[req]; ok {
			req = canon
		}
	}
	// Now check if the question has the requested category as a tag
	// We only match against canonical categories to avoid cross-category pollution
	for _, t := range tags {
		// Direct match with canonical category
		if t == req {
			if _, ok := canonicalCategories[t]; ok {
				return true
			}
		}
		// Match via alias
		if canon, ok := categoryAliases[t]; ok {
			if canon == req {
				return true
			}
		}
	}
	return false
}
