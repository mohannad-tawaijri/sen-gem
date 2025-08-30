# sen-gem server (Go + Gin)

Back-end API to add users, Google login, DB, and per-user non-repeating questions.

## Roadmap (high level)

1) Bootstrap server
   - Gin app, CORS, health endpoint ✅
   - Env config file (.env) and defaults ✅

2) Database + models
   - Pick SQLite (dev) and Postgres (prod) via GORM
   - Models: User, QuestionSeen (or UserQuestion), optionally UserSession
   - Auto-migrations

3) Google OAuth2 login
   - Authorization Code flow: /auth/google/login, /auth/google/callback
   - Cookie session (secure, HttpOnly)
   - /me and /auth/logout endpoints

4) Questions service
   - Load questions JSONs from QUESTIONS_DIR at startup
   - Index by id/category/difficulty
   - API: GET /questions/next?category=...&difficulty=...
     - Pick unseen for user, mark as seen
   - POST /questions/reset (optional filters)

5) Front-end wiring (Vue)
   - Login button -> redirects to /auth/google/login
   - Show user in header from /me
   - Call /questions/next and display

6) Production hardening
   - CSRF, HTTPS/Proxy headers, secure cookies
   - Rate limiting, logging, error handling

## Run locally (PowerShell)

- Install Go 1.22+ on Windows from go.dev and reopen PowerShell: `go version`
- Copy env: `cp .env.example .env` (or create manually on Windows)
- Install deps and run:
   - `go mod tidy`
   - `go run .`

By default it listens on :8080 and allows CORS from http://localhost:5173.

## Data design (draft)

- User: id, googleID, email, name, picture, createdAt
- QuestionSeen: id, userId, questionId, category, difficulty, seenAt
  - Next question picks a random unseen matching filters
  - Reset simply deletes rows for that user (+ optional scope)

Alternative: maintain a per-user-per-scope shuffled list; advance pointer; reset rewinds.

## DB choice for production

- Development: SQLite is simplest and reliable.
- Production: Postgres is recommended (managed service like Cloud SQL, RDS, or Supabase). Set `DATABASE_URL` to a Postgres DSN.

## Next steps to implement

- [ ] Add GORM + DB wiring (SQLite default)
- [ ] Models + migrations
- [ ] Session middleware
- [ ] Google OAuth routes
- [ ] Questions loader + next/reset endpoints
- [ ] Minimal integration docs for Vue app
