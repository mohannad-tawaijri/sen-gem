package main

import (
	"log"
	"net/http"
	"strconv"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	"server/auth"
	"server/config"
	"server/db"
	"server/models"
	"server/questions"
)

func main() {
	cfg := config.Load()

	// DB
	gormDB, err := db.Open(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("db open: %v", err)
	}
	if err := db.AutoMigrate(gormDB, &models.User{}, &models.QuestionSeen{}); err != nil {
		log.Fatalf("migrate: %v", err)
	}

	// Sessions
	// For dev we don't set a domain and secure=false; in prod set them properly
	sess := auth.NewSessionManager(cfg.SessionSecret, "", false)

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
		type signupReq struct{ Email, Password, Name string }
		api.POST("/auth/signup", func(c *gin.Context) {
			var r signupReq
			if err := c.BindJSON(&r); err != nil || r.Email == "" || r.Password == "" {
				c.JSON(http.StatusBadRequest, gin.H{"error": "email and password required"})
				return
			}
			// hash
			hash, err := auth.HashPassword(r.Password)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "hash failed"})
				return
			}
			u := models.User{Email: r.Email, Name: r.Name, PasswordHash: hash}
			if err := gormDB.Create(&u).Error; err != nil {
				c.JSON(http.StatusConflict, gin.H{"error": "email already exists"})
				return
			}
			sess.SetUser(c.Writer, strconv.FormatUint(uint64(u.ID), 10))
			c.JSON(http.StatusCreated, gin.H{"user": u})
		})

		// Local login
		type loginReq struct{ Email, Password string }
		api.POST("/auth/login", func(c *gin.Context) {
			var r loginReq
			if err := c.BindJSON(&r); err != nil || r.Email == "" || r.Password == "" {
				c.JSON(http.StatusBadRequest, gin.H{"error": "email and password required"})
				return
			}
			var u models.User
			if err := gormDB.Where("email = ?", r.Email).First(&u).Error; err != nil {
				c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
				return
			}
			if !auth.CheckPassword(u.PasswordHash, r.Password) {
				c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
				return
			}
			sess.SetUser(c.Writer, strconv.FormatUint(uint64(u.ID), 10))
			c.JSON(http.StatusOK, gin.H{"user": u})
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
			// total candidates
			total := 0
			for _, q := range qsvc.All() {
				if f.Difficulty != 0 && q.Difficulty != f.Difficulty {
					continue
				}
				if f.Category != "" {
					has := false
					for _, t := range q.Tags {
						if t == f.Category {
							has = true
							break
						}
					}
					if !has {
						continue
					}
				}
				total++
			}
			c.JSON(http.StatusOK, gin.H{"seen": seen, "total": total, "remaining": total - int(seen)})
		})
	}

	// OAuth routes
	gp := auth.NewGoogleProvider(cfg.GoogleClientID, cfg.GoogleClientSecret, cfg.OAuthRedirectURL, gormDB, sess)
	if cfg.AfterLoginRedirect != "" {
		gp.SetRedirectOK(cfg.AfterLoginRedirect)
	}
	r.GET("/auth/google/login", func(c *gin.Context) { gp.Login(c.Writer, c.Request) })
	r.GET("/auth/google/callback", func(c *gin.Context) { gp.Callback(c.Writer, c.Request) })

	log.Printf("server listening on :%s (frontend %s)", cfg.Port, cfg.FrontendOrigin)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatal(err)
	}
}
