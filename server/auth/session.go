package auth

import (
    "crypto/hmac"
    "crypto/sha256"
    "encoding/base64"
    "net/http"
    "time"
)

// Minimal signed-cookie session for user ID

const cookieName = "sengem_session"

type SessionManager struct {
    secret []byte
    // cookie options
    domain   string
    secure   bool
    sameSite http.SameSite
}

func NewSessionManager(secret, domain string, secure bool) *SessionManager {
    return &SessionManager{
        secret:   []byte(secret),
        domain:   domain,
        secure:   secure,
        sameSite: http.SameSiteLaxMode,
    }
}

func (s *SessionManager) Sign(value string) string {
    mac := hmac.New(sha256.New, s.secret)
    mac.Write([]byte(value))
    sig := mac.Sum(nil)
    return value + "." + base64.RawURLEncoding.EncodeToString(sig)
}

func (s *SessionManager) Verify(signed string) (string, bool) {
    parts := []byte(signed)
    // find last '.'
    idx := -1
    for i := len(parts) - 1; i >= 0; i-- {
        if parts[i] == '.' {
            idx = i
            break
        }
    }
    if idx <= 0 {
        return "", false
    }
    value := string(parts[:idx])
    expSig, err := base64.RawURLEncoding.DecodeString(string(parts[idx+1:]))
    if err != nil {
        return "", false
    }
    mac := hmac.New(sha256.New, s.secret)
    mac.Write([]byte(value))
    sig := mac.Sum(nil)
    if !hmac.Equal(sig, expSig) {
        return "", false
    }
    return value, true
}

func (s *SessionManager) SetUser(w http.ResponseWriter, userID string) {
    http.SetCookie(w, &http.Cookie{
        Name:     cookieName,
        Value:    s.Sign(userID),
        Path:     "/",
        Domain:   s.domain,
        Expires:  time.Now().Add(30 * 24 * time.Hour),
        HttpOnly: true,
        Secure:   s.secure,
        SameSite: s.sameSite,
    })
}

func (s *SessionManager) Clear(w http.ResponseWriter) {
    http.SetCookie(w, &http.Cookie{
        Name:     cookieName,
        Value:    "",
        Path:     "/",
        Domain:   s.domain,
        Expires:  time.Unix(0, 0),
        HttpOnly: true,
        Secure:   s.secure,
        SameSite: s.sameSite,
    })
}

func (s *SessionManager) GetUserID(r *http.Request) (string, bool) {
    c, err := r.Cookie(cookieName)
    if err != nil {
        return "", false
    }
    return s.Verify(c.Value)
}
