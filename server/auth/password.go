package auth

import "golang.org/x/crypto/bcrypt"

func HashPassword(pw string) (string, error) {
	b, err := bcrypt.GenerateFromPassword([]byte(pw), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(b), nil
}

func CheckPassword(hash, pw string) bool {
	return bcrypt.CompareHashAndPassword([]byte(hash), []byte(pw)) == nil
}

// ValidatePassword enforces minimum policy (length >= 8, contains letter and digit)
func ValidatePassword(pw string) error {
	if len(pw) < 8 {
		return errWeakPassword{"must be at least 8 characters"}
	}
	hasLetter, hasDigit := false, false
	for _, r := range pw {
		switch {
		case r >= 'A' && r <= 'Z', r >= 'a' && r <= 'z':
			hasLetter = true
		case r >= '0' && r <= '9':
			hasDigit = true
		}
	}
	if !hasLetter || !hasDigit {
		return errWeakPassword{"must include letters and digits"}
	}
	return nil
}

type errWeakPassword struct{ msg string }

func (e errWeakPassword) Error() string { return "weak password: " + e.msg }
