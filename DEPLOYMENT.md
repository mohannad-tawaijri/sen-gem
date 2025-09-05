# Production Deployment

This repo has two parts:
- Frontend: `sinjeem-game` (Vue 3 + Vite)
- Backend: `server` (Go + Gin + SQLite/Postgres)

You can deploy in two ways:

1) Single container (recommended): Go server serves the built SPA
2) Split: Serve SPA via static host/CDN and run the Go API separately

## 1) Single Docker image

Prereqs: Docker 24+

Build the image:

```sh
docker build -t sengem:latest .
```

Run it:

```sh
docker run --rm -p 8080:8080 ^
  -e APP_ENV=production ^
  -e SESSION_SECRET=<strong-secret> ^
  -e FRONTEND_ORIGIN=http://localhost:8080 ^
  sengem:latest
```

Visit http://localhost:8080

Environment variables (see `.env.example`):
- FRONTEND_DIR: set to `/app/web` inside the container (already configured)
- QUESTIONS_DIR: defaults to `/app/questions` from the image. To override with a mounted volume:

```sh
docker run --rm -p 8080:8080 ^
  -v C:\path\to\questions:/app/questions ^
  sengem:latest
```

To use Postgres instead of SQLite:
```sh
docker run --rm -p 8080:8080 ^
  -e DATABASE_URL="postgres://user:pass@host:5432/db?sslmode=disable" ^
  sengem:latest
```

## 2) Split frontend and backend

Build the SPA:
```sh
cd sinjeem-game
npm ci
npm run build
```
Host `sinjeem-game/dist/` on any static host (Nginx, S3+CloudFront, Vercel, Netlify). Set `FRONTEND_ORIGIN` on the server to that public URL and do NOT set `FRONTEND_DIR`.

Run the API server:
```sh
set APP_ENV=production
set PORT=8080
set FRONTEND_ORIGIN=https://your-frontend.example.com
set SESSION_SECRET=<strong-secret>
set QUESTIONS_DIR=./sinjeem-game/public/questions
go run ./server
```

Notes:
- Cookies default to `SameSite=Lax` and `Secure=true` in production (over HTTPS). If you run on plain HTTP behind a reverse proxy, terminate TLS at the proxy.
- CORS allows only `FRONTEND_ORIGIN` so ensure it matches your public URL exactly.
- `AFTER_LOGIN_REDIRECT` should point to your SPA entry (e.g., `https://.../#/`).
