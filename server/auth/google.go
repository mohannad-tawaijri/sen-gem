package auth

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"math/rand"
	"net/http"
	"time"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"gorm.io/gorm"
)

type GoogleProvider struct {
	cfg        *oauth2.Config
	db         *gorm.DB
	sessions   *SessionManager
	redirectOK string
}

func NewGoogleProvider(clientID, clientSecret, redirectURL string, db *gorm.DB, sessions *SessionManager) *GoogleProvider {
	return &GoogleProvider{
		cfg: &oauth2.Config{
			ClientID:     clientID,
			ClientSecret: clientSecret,
			RedirectURL:  redirectURL,
			Scopes: []string{
				"openid", "email", "profile",
			},
			Endpoint: google.Endpoint,
		},
		db:         db,
		sessions:   sessions,
		redirectOK: "/", // will be overridden by main via setter
	}
}

func (gp *GoogleProvider) SetRedirectOK(url string) { gp.redirectOK = url }

// state cookie to prevent CSRF
const stateCookie = "sengem_oauth_state"

func randomState() string {
	const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	b := make([]byte, 24)
	rand.Seed(time.Now().UnixNano())
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}

func (gp *GoogleProvider) Login(w http.ResponseWriter, r *http.Request) {
	if gp.cfg.ClientID == "" || gp.cfg.ClientSecret == "" {
		http.Error(w, "Google OAuth not configured: set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET in .env", http.StatusInternalServerError)
		return
	}
	st := randomState()
	http.SetCookie(w, &http.Cookie{
		Name:     stateCookie,
		Value:    gp.sessions.Sign(st),
		Path:     "/",
		HttpOnly: true,
		Expires:  time.Now().Add(10 * time.Minute),
		SameSite: http.SameSiteLaxMode,
	})
	url := gp.cfg.AuthCodeURL(st, oauth2.AccessTypeOnline)
	http.Redirect(w, r, url, http.StatusFound)
}

type googleUserInfo struct {
	ID      string `json:"id"`
	Email   string `json:"email"`
	Name    string `json:"name"`
	Picture string `json:"picture"`
}

func fetchUserInfo(ctx context.Context, client *http.Client) (*googleUserInfo, error) {
	// Google OAuth2 v2 userinfo endpoint
	resp, err := client.Get("https://www.googleapis.com/oauth2/v2/userinfo")
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("userinfo status %d: %s", resp.StatusCode, string(body))
	}
	var ui googleUserInfo
	if err := json.NewDecoder(resp.Body).Decode(&ui); err != nil {
		return nil, err
	}
	return &ui, nil
}

// Upsert user and set session
func (gp *GoogleProvider) Callback(w http.ResponseWriter, r *http.Request) {
	// verify state
	st := r.URL.Query().Get("state")
	code := r.URL.Query().Get("code")
	if st == "" || code == "" {
		http.Error(w, "invalid oauth response", http.StatusBadRequest)
		return
	}
	c, err := r.Cookie(stateCookie)
	if err != nil {
		http.Error(w, "missing state cookie", http.StatusBadRequest)
		return
	}
	if val, ok := gp.sessions.Verify(c.Value); !ok || val != st {
		http.Error(w, "state mismatch", http.StatusBadRequest)
		return
	}

	ctx := context.Background()
	tok, err := gp.cfg.Exchange(ctx, code)
	if err != nil {
		http.Error(w, "oauth exchange failed", http.StatusBadRequest)
		return
	}
	client := gp.cfg.Client(ctx, tok)
	ui, err := fetchUserInfo(ctx, client)
	if err != nil {
		http.Error(w, "failed to fetch user info", http.StatusBadRequest)
		return
	}

	// Upsert user in DB
	type userModel interface{ TableName() string }
	// avoid direct import cycles, we know the fields
	var id uint
	err = gp.db.Transaction(func(tx *gorm.DB) error {
		// raw SQL to avoid import cycle; keep simple with gorm model map
		// We'll use a small struct inline
		type User struct {
			ID       uint   `gorm:"primaryKey"`
			GoogleID string `gorm:"uniqueIndex"`
			Email    string
			Name     string
			Picture  string
		}
		var u User
		if err := tx.Where(&User{GoogleID: ui.ID}).First(&u).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				u = User{GoogleID: ui.ID, Email: ui.Email, Name: ui.Name, Picture: ui.Picture}
				if err := tx.Create(&u).Error; err != nil {
					return err
				}
			} else {
				return err
			}
		} else {
			// update basic fields
			u.Email = ui.Email
			u.Name = ui.Name
			u.Picture = ui.Picture
			if err := tx.Save(&u).Error; err != nil {
				return err
			}
		}
		id = u.ID
		return nil
	})
	if err != nil {
		http.Error(w, "db error", http.StatusInternalServerError)
		return
	}

	gp.sessions.SetUser(w, fmt.Sprintf("%d", id))
	http.Redirect(w, r, gp.redirectOK, http.StatusFound)
}
