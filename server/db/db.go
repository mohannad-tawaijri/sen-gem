package db

import (
	"fmt"
	"log"
	"strings"

	sqlite "github.com/glebarez/sqlite"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func Open(databaseURL string) (*gorm.DB, error) {
	lower := strings.ToLower(databaseURL)
	switch {
	case strings.HasPrefix(lower, "postgres://") || strings.HasPrefix(lower, "postgresql://"):
		return gorm.Open(postgres.Open(databaseURL), &gorm.Config{})
	case strings.HasPrefix(lower, "file:") || strings.HasSuffix(lower, ".db") || lower == ":memory:":
		// SQLite path or DSN
		return gorm.Open(sqlite.Open(strings.TrimPrefix(databaseURL, "file:")), &gorm.Config{})
	default:
		log.Printf("[db] Unrecognized DATABASE_URL, defaulting to sqlite file: %s", databaseURL)
		return gorm.Open(sqlite.Open(databaseURL), &gorm.Config{})
	}
}

func AutoMigrate(g *gorm.DB, models ...interface{}) error {
	if err := g.AutoMigrate(models...); err != nil {
		return fmt.Errorf("auto-migrate: %w", err)
	}
	return nil
}
