package questions

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"os"
	"path/filepath"
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
	all []Question
	db  *gorm.DB
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
	qs, err := loadFromDir(dir)
	if err != nil {
		return nil, err
	}
	return &Service{all: qs, db: db}, nil
}

// All returns the loaded questions list (read-only copy)
func (s *Service) All() []Question {
	out := make([]Question, len(s.all))
	copy(out, s.all)
	return out
}

// FindByID returns the question by its ID if it exists
func (s *Service) FindByID(id string) *Question {
	for i := range s.all {
		if s.all[i].ID == id {
			return &s.all[i]
		}
	}
	return nil
}

func loadFromDir(dir string) ([]Question, error) {
	var out []Question
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
		b, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		var arr []Question
		if err := json.Unmarshal(b, &arr); err != nil {
			// ignore files that are not arrays of questions
			return nil
		}
		// ensure each question has the file's category slug as a tag
		base := strings.TrimSuffix(info.Name(), filepath.Ext(info.Name()))
		slug := canonicalizeSlug(base)
		for i := range arr {
			if !sliceContains(arr[i].Tags, slug) {
				arr[i].Tags = append(arr[i].Tags, slug)
			}
		}
		out = append(out, arr...)
		return nil
	})
	return out, err
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
	q := s.FindByID(qid)
	if q == nil {
		return false, fmt.Errorf("question not found")
	}
	return s.tryMarkSeen(userID, *q)
}

// MatchesCategory checks if any of the question tags match the requested category (with alias)
func MatchesCategory(tags []string, requested string) bool {
	req := requested
	// normalize requested if it's an alias key (we accept canonical slugs from UI)
	// Here aliases map is from data tag -> canonical; requested usually is canonical already
	for _, t := range tags {
		if t == req {
			return true
		}
		if canon, ok := categoryAliases[t]; ok && canon == req {
			return true
		}
	}
	return false
}
