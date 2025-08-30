package models

import (
	"time"
)

type User struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`

	GoogleID     string `gorm:"uniqueIndex" json:"googleId"`
	Email        string `gorm:"uniqueIndex" json:"email"`
	Name         string `json:"name"`
	Picture      string `json:"picture"`
	PasswordHash string `json:"-"`
}

type QuestionSeen struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"seenAt"`

	UserID     uint   `gorm:"index;uniqueIndex:uq_user_q" json:"userId"`
	QuestionID string `gorm:"index;uniqueIndex:uq_user_q" json:"questionId"`
	Category   string `gorm:"index" json:"category"`
	Difficulty int    `gorm:"index" json:"difficulty"`
}
