package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

// Get returns env var or default
func Get(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

type AppConfig struct {
	Env            string
	Port           string
	FrontendOrigin string
	FrontendDir    string
	DatabaseURL    string
	SessionSecret  string
	QuestionsDir   string

	GoogleClientID     string
	GoogleClientSecret string
	OAuthRedirectURL   string

	AfterLoginRedirect string
}

func Load() AppConfig {
	// Try loading .env if present for local development
	_ = godotenv.Load()
	cfg := AppConfig{
		Env:                Get("APP_ENV", "development"),
		Port:               Get("PORT", "8080"),
		FrontendOrigin:     Get("FRONTEND_ORIGIN", "http://localhost:5173"),
		FrontendDir:        Get("FRONTEND_DIR", ""),
		DatabaseURL:        Get("DATABASE_URL", "file:server.db"),
		SessionSecret:      Get("SESSION_SECRET", "dev-insecure-secret-change-me"),
		QuestionsDir:       Get("QUESTIONS_DIR", "../sinjeem-game/public/questions"),
		GoogleClientID:     Get("GOOGLE_CLIENT_ID", ""),
		GoogleClientSecret: Get("GOOGLE_CLIENT_SECRET", ""),
		OAuthRedirectURL:   Get("OAUTH_REDIRECT_URL", "http://localhost:8080/auth/google/callback"),
		AfterLoginRedirect: Get("AFTER_LOGIN_REDIRECT", "http://localhost:5173/#/"),
	}
	if cfg.SessionSecret == "dev-insecure-secret-change-me" {
		log.Println("[warn] SESSION_SECRET is using default value; set a strong secret in production")
	}
	return cfg
}
