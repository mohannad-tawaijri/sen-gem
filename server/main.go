package main

import (
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	"regexp"
	"server/auth"
	"server/config"
	"server/db"
	"server/models"
	"server/questions"
	"strings"
)

func main() {
	cfg := config.Load()

	// Use release mode in production
	if cfg.Env == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// DB
	gormDB, err := db.Open(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("db open: %v", err)
	}
	if err := db.AutoMigrate(gormDB, &models.User{}, &models.QuestionSeen{}, &models.VerificationToken{}, &models.PasswordResetToken{}); err != nil {
		log.Fatalf("migrate: %v", err)
	}

	// Data fix: older rows may have google_id = "" which conflicts with UNIQUE.
	// Convert empty strings to NULL so multiple local accounts are allowed.
	if err := gormDB.Exec("UPDATE users SET google_id = NULL WHERE google_id = ''").Error; err != nil {
		log.Printf("[warn] failed to normalize google_id empties: %v", err)
	}

	// Sessions
	// Secure cookies in production
	secureCookies := cfg.Env == "production"
	sess := auth.NewSessionManager(cfg.SessionSecret, "", secureCookies)

	// Rate limiter: 10 req per 5m; lockout after 5 bad attempts for 15m
	rl := auth.NewRateLimiter(5*time.Minute, 10, 5, 15*time.Minute)

	r := gin.Default()
	// Do not trust any proxies by default (explicitness avoids warnings)
	_ = r.SetTrustedProxies(nil)
	// CORS for the Vue app
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{cfg.FrontendOrigin},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		AllowCredentials: true,
	}))

	// Basic security headers
	r.Use(func(c *gin.Context) {
		c.Header("X-Content-Type-Options", "nosniff")
		c.Header("X-Frame-Options", "DENY")
		c.Header("Referrer-Policy", "no-referrer")
		// minimal CSP (adjust as needed)
		c.Header("Content-Security-Policy", "default-src 'self' 'unsafe-inline' http: https: data:")
		c.Next()
	})

	// CSRF-ish origin check for state-changing requests (dev-friendly)
	r.Use(func(c *gin.Context) {
		if c.Request.Method == http.MethodGet || c.Request.Method == http.MethodHead || c.Request.Method == http.MethodOptions {
			c.Next()
			return
		}
		origin := c.Request.Header.Get("Origin")
		if origin == "" || origin == cfg.FrontendOrigin {
			c.Next()
			return
		}
		c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "forbidden origin"})
	})

	// Questions service
	qsvc, qerr := questions.NewService(cfg.QuestionsDir, gormDB)
	if qerr != nil {
		log.Printf("[warn] failed loading questions: %v", qerr)
	}

	api := r.Group("/api")
	{
		api.GET("/health", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"status": "ok"})
		})

		// Minimal auth stubs until Google OAuth is added
		api.GET("/me", func(c *gin.Context) {
			if uid, ok := sess.GetUserID(c.Request); ok {
				var user models.User
				if err := gormDB.First(&user, uid).Error; err == nil {
					c.JSON(http.StatusOK, gin.H{"user": user})
					return
				}
				c.JSON(http.StatusOK, gin.H{"userId": uid})
				return
			}
			c.JSON(http.StatusOK, gin.H{"user": nil})
		})
		api.POST("/auth/logout", func(c *gin.Context) {
			sess.Clear(c.Writer)
			c.Status(http.StatusNoContent)
		})

		// Local signup
		type signupReq struct{ Email, Username, Password, Name string }
		api.POST("/auth/signup", func(c *gin.Context) {
			if ok, locked, retry := rl.Allow(c.Request, "signup"); !ok {
				if locked {
					c.Header("Retry-After", retry.String())
					c.JSON(http.StatusTooManyRequests, gin.H{"error": "temporarily locked"})
					return
				}
				c.Header("Retry-After", retry.String())
				c.JSON(http.StatusTooManyRequests, gin.H{"error": "rate limited"})
				return
			}
			var r signupReq
			if err := c.BindJSON(&r); err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": "invalid json"})
				return
			}
			// Enforce both email and username for signup
			r.Email = strings.ToLower(strings.TrimSpace(r.Email))
			r.Username = strings.TrimSpace(r.Username)
			if r.Email == "" || r.Username == "" || r.Password == "" {
				c.JSON(http.StatusBadRequest, gin.H{"error": "email, username and password required"})
				return
			}
			// Simple validations
			if !strings.Contains(r.Email, "@") {
				c.JSON(http.StatusBadRequest, gin.H{"error": "invalid email"})
				return
			}
			if ok, _ := regexp.MatchString(`^[a-zA-Z0-9_]{3,20}$`, r.Username); !ok {
				c.JSON(http.StatusBadRequest, gin.H{"error": "invalid username"})
				return
			}
			if err := auth.ValidatePassword(r.Password); err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
				return
			}
			// Prevent duplicates explicitly (in case DB unique index is missing)
			var existing models.User
			if err := gormDB.Where("email = ?", r.Email).Or("username = ?", r.Username).First(&existing).Error; err == nil {
				// Determine which field conflicts (best-effort)
				if existing.Email == r.Email {
					c.JSON(http.StatusConflict, gin.H{"error": "email already exists"})
				} else {
					c.JSON(http.StatusConflict, gin.H{"error": "username already exists"})
				}
				return
			}
			// hash
			hash, err := auth.HashPassword(r.Password)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "hash failed"})
				return
			}
			u := models.User{Email: r.Email, Username: r.Username, Name: r.Name, PasswordHash: hash}
			if err := gormDB.Create(&u).Error; err != nil {
				c.JSON(http.StatusConflict, gin.H{"error": "username or email already exists"})
				return
			}
			sess.SetUser(c.Writer, strconv.FormatUint(uint64(u.ID), 10))
			c.JSON(http.StatusCreated, gin.H{"user": u})
		})

		// Local login
		type loginReq struct{ Email, Username, Password string }
		api.POST("/auth/login", func(c *gin.Context) {
			if ok, locked, retry := rl.Allow(c.Request, "login:"+c.ClientIP()); !ok {
				if locked {
					c.Header("Retry-After", retry.String())
					c.JSON(http.StatusTooManyRequests, gin.H{"error": "temporarily locked"})
					return
				}
				c.Header("Retry-After", retry.String())
				c.JSON(http.StatusTooManyRequests, gin.H{"error": "rate limited"})
				return
			}
			var r loginReq
			if err := c.BindJSON(&r); err != nil || (r.Email == "" && r.Username == "") || r.Password == "" {
				c.JSON(http.StatusBadRequest, gin.H{"error": "email or username and password required"})
				return
			}
			var u models.User
			q := gormDB
			if r.Email != "" {
				q = q.Where("email = ?", r.Email)
			} else {
				q = q.Where("username = ?", r.Username)
			}
			if err := q.First(&u).Error; err != nil {
				rl.Fail(c.Request, "login:"+r.Email)
				c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
				return
			}
			if !auth.CheckPassword(u.PasswordHash, r.Password) {
				rl.Fail(c.Request, "login:"+r.Email)
				c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
				return
			}
			sess.SetUser(c.Writer, strconv.FormatUint(uint64(u.ID), 10))
			c.JSON(http.StatusOK, gin.H{"user": u})
		})

		// Request email verification (dev: logs URL)
		api.POST("/auth/verify/request", func(c *gin.Context) {
			uidStr, ok := sess.GetUserID(c.Request)
			if !ok {
				c.JSON(http.StatusUnauthorized, gin.H{"error": "not authenticated"})
				return
			}
			uid64, _ := strconv.ParseUint(uidStr, 10, 64)
			token := strconv.FormatInt(time.Now().UnixNano(), 36)
			vt := models.VerificationToken{UserID: uint(uid64), Token: token, ExpiresAt: time.Now().Add(24 * time.Hour)}
			if err := gormDB.Create(&vt).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "could not create token"})
				return
			}
			// Log the URL (in production, email it)
			link := "/api/auth/verify?token=" + token
			log.Printf("[verify] open: %s", link)
			c.Status(http.StatusNoContent)
		})

		// Verify email by token
		api.GET("/auth/verify", func(c *gin.Context) {
			token := c.Query("token")
			if token == "" {
				c.JSON(http.StatusBadRequest, gin.H{"error": "missing token"})
				return
			}
			var vt models.VerificationToken
			if err := gormDB.Where("token = ?", token).First(&vt).Error; err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": "invalid token"})
				return
			}
			if time.Now().After(vt.ExpiresAt) {
				c.JSON(http.StatusBadRequest, gin.H{"error": "token expired"})
				return
			}
			if err := gormDB.Model(&models.User{}).Where("id = ?", vt.UserID).Update("verified", true).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "update failed"})
				return
			}
			_ = gormDB.Delete(&vt).Error
			c.JSON(http.StatusOK, gin.H{"status": "verified"})
		})

		// Request password reset (dev: logs link)
		api.POST("/auth/password/reset/request", func(c *gin.Context) {
			var body struct{ Email string }
			if err := c.BindJSON(&body); err != nil || body.Email == "" {
				c.JSON(http.StatusBadRequest, gin.H{"error": "email required"})
				return
			}
			var u models.User
			if err := gormDB.Where("email = ?", body.Email).First(&u).Error; err == nil {
				token := strconv.FormatInt(time.Now().UnixNano(), 36)
				rt := models.PasswordResetToken{UserID: u.ID, Token: token, ExpiresAt: time.Now().Add(1 * time.Hour)}
				_ = gormDB.Create(&rt).Error
				log.Printf("[reset] open: /api/auth/password/reset?token=%s", token)
			}
			// Always return 204 to avoid user enumeration
			c.Status(http.StatusNoContent)
		})

		// Perform password reset
		api.POST("/auth/password/reset", func(c *gin.Context) {
			var body struct{ Token, NewPassword string }
			if err := c.BindJSON(&body); err != nil || body.Token == "" || body.NewPassword == "" {
				c.JSON(http.StatusBadRequest, gin.H{"error": "token and newPassword required"})
				return
			}
			if err := auth.ValidatePassword(body.NewPassword); err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
				return
			}
			var rt models.PasswordResetToken
			if err := gormDB.Where("token = ?", body.Token).First(&rt).Error; err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": "invalid token"})
				return
			}
			if time.Now().After(rt.ExpiresAt) {
				c.JSON(http.StatusBadRequest, gin.H{"error": "token expired"})
				return
			}
			hash, err := auth.HashPassword(body.NewPassword)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "hash failed"})
				return
			}
			if err := gormDB.Model(&models.User{}).Where("id = ?", rt.UserID).Update("password_hash", hash).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "update failed"})
				return
			}
			_ = gormDB.Delete(&rt).Error
			c.Status(http.StatusNoContent)
		})

		// Next question
		api.GET("/questions/next", func(c *gin.Context) {
			if qsvc == nil {
				c.JSON(http.StatusServiceUnavailable, gin.H{"error": "questions not loaded"})
				return
			}
			uidStr, ok := sess.GetUserID(c.Request)
			if !ok {
				c.JSON(http.StatusUnauthorized, gin.H{"error": "not authenticated"})
				return
			}
			uid64, _ := strconv.ParseUint(uidStr, 10, 64)
			var f questions.Filter
			if v := c.Query("category"); v != "" {
				f.Category = v
			}
			if v := c.Query("difficulty"); v != "" {
				if d, err := strconv.Atoi(v); err == nil {
					f.Difficulty = d
				}
			}
			q, err := qsvc.NextForUser(uint(uid64), f)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
				return
			}
			if q == nil {
				c.JSON(http.StatusOK, gin.H{"question": nil, "message": "no unseen questions"})
				return
			}
			c.JSON(http.StatusOK, gin.H{"question": q})
		})

		// Mark a specific question as seen (id in JSON body)
		api.POST("/questions/seen", func(c *gin.Context) {
			if qsvc == nil {
				c.JSON(http.StatusServiceUnavailable, gin.H{"error": "questions not loaded"})
				return
			}
			uidStr, ok := sess.GetUserID(c.Request)
			if !ok {
				c.JSON(http.StatusUnauthorized, gin.H{"error": "not authenticated"})
				return
			}
			uid64, _ := strconv.ParseUint(uidStr, 10, 64)
			var body struct {
				ID string `json:"id"`
			}
			if err := c.BindJSON(&body); err != nil || strings.TrimSpace(body.ID) == "" {
				c.JSON(http.StatusBadRequest, gin.H{"error": "id required"})
				return
			}
			newly, err := qsvc.MarkSeenByID(uint(uid64), body.ID)
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
				return
			}
			c.JSON(http.StatusOK, gin.H{"new": newly})
		})

		// Reset
		api.POST("/questions/reset", func(c *gin.Context) {
			if qsvc == nil {
				c.JSON(http.StatusServiceUnavailable, gin.H{"error": "questions not loaded"})
				return
			}
			uidStr, ok := sess.GetUserID(c.Request)
			if !ok {
				c.JSON(http.StatusUnauthorized, gin.H{"error": "not authenticated"})
				return
			}
			uid64, _ := strconv.ParseUint(uidStr, 10, 64)
			var f questions.Filter
			// allow form or query
			if v := c.Query("category"); v != "" {
				f.Category = v
			}
			if v := c.Query("difficulty"); v != "" {
				if d, err := strconv.Atoi(v); err == nil {
					f.Difficulty = d
				}
			}
			if err := qsvc.ResetUser(uint(uid64), f); err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
				return
			}
			c.Status(http.StatusNoContent)
		})

		// Stats: seen and remaining counts
		api.GET("/questions/stats", func(c *gin.Context) {
			if qsvc == nil {
				c.JSON(http.StatusServiceUnavailable, gin.H{"error": "questions not loaded"})
				return
			}
			uidStr, ok := sess.GetUserID(c.Request)
			if !ok {
				c.JSON(http.StatusUnauthorized, gin.H{"error": "not authenticated"})
				return
			}
			uid64, _ := strconv.ParseUint(uidStr, 10, 64)
			var f questions.Filter
			if v := c.Query("category"); v != "" {
				f.Category = v
			}
			if v := c.Query("difficulty"); v != "" {
				if d, err := strconv.Atoi(v); err == nil {
					f.Difficulty = d
				}
			}
			// count seen
			q := gormDB.Table("question_seens").Where("user_id = ?", uint(uid64))
			if f.Difficulty != 0 {
				q = q.Where("difficulty = ?", f.Difficulty)
			}
			if f.Category != "" {
				q = q.Where("category = ?", f.Category)
			}
			var seen int64
			if err := q.Count(&seen).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
				return
			}
			// total candidates (respect aliases/canonical mapping)
			total := 0
			for _, q := range qsvc.All() {
				if f.Difficulty != 0 && q.Difficulty != f.Difficulty {
					continue
				}
				if f.Category != "" && !questions.MatchesCategory(q.Tags, f.Category) {
					continue
				}
				total++
			}
			c.JSON(http.StatusOK, gin.H{"seen": seen, "total": total, "remaining": total - int(seen)})
		})
	}

	// OAuth routes
	gp := auth.NewGoogleProvider(cfg.GoogleClientID, cfg.GoogleClientSecret, cfg.OAuthRedirectURL, gormDB, sess, cfg.FrontendOrigin)
	if cfg.AfterLoginRedirect != "" {
		gp.SetRedirectOK(cfg.AfterLoginRedirect)
	}
	r.GET("/auth/google/login", func(c *gin.Context) { gp.Login(c.Writer, c.Request) })
	r.GET("/auth/google/callback", func(c *gin.Context) { gp.Callback(c.Writer, c.Request) })

	// Optionally serve prebuilt frontend (Vite dist) when FRONTEND_DIR is set
	if cfg.FrontendDir != "" {
		// SPA serving without registering a wildcard route (avoid conflicts with /api, /auth)
		r.NoRoute(func(c *gin.Context) {
			if c.Request.Method != http.MethodGet {
				c.Status(http.StatusNotFound)
				return
			}
			// Try to serve an existing static file from FRONTEND_DIR
			reqPath := c.Request.URL.Path
			if reqPath == "/" || reqPath == "" {
				c.File(filepath.Join(cfg.FrontendDir, "index.html"))
				return
			}
			// Clean and join path
			clean := filepath.Clean(reqPath)
			// prevent path traversal
			if len(clean) > 0 && clean[0] == '/' {
				clean = clean[1:]
			}
			fsPath := filepath.Join(cfg.FrontendDir, clean)
			if info, err := os.Stat(fsPath); err == nil && !info.IsDir() {
				c.File(fsPath)
				return
			}
			// Fallback to index.html for SPA routes
			c.File(filepath.Join(cfg.FrontendDir, "index.html"))
		})
	}

	log.Printf("server listening on :%s (frontend %s)", cfg.Port, cfg.FrontendOrigin)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatal(err)
	}
}
