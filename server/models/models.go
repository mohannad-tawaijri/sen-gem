package models

import (
	"time"
)

type User struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`

	GoogleID     *string `gorm:"uniqueIndex" json:"googleId,omitempty"`
	Username     string  `gorm:"uniqueIndex" json:"username"`
	Email        string  `gorm:"uniqueIndex" json:"email"`
	Name         string  `json:"name"`
	Picture      string  `json:"picture"`
	PasswordHash string  `json:"-"`
	Verified     bool    `json:"verified"`
}

type QuestionSeen struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"seenAt"`

	UserID     uint   `gorm:"index;uniqueIndex:uq_user_q" json:"userId"`
	QuestionID string `gorm:"index;uniqueIndex:uq_user_q" json:"questionId"`
	Category   string `gorm:"index" json:"category"`
	Difficulty int    `gorm:"index" json:"difficulty"`
}

type VerificationToken struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"createdAt"`
	ExpiresAt time.Time `json:"expiresAt"`

	UserID uint   `gorm:"index" json:"userId"`
	Token  string `gorm:"uniqueIndex" json:"token"`
}

type PasswordResetToken struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"createdAt"`
	ExpiresAt time.Time `json:"expiresAt"`

	UserID uint   `gorm:"index" json:"userId"`
	Token  string `gorm:"uniqueIndex" json:"token"`
}
