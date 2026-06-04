# 🎮 سين جيم (Sin Jeem)

<div align="center">

![Vue](https://img.shields.io/badge/Vue-3.5-42b883.svg)
![Go](https://img.shields.io/badge/Go-1.22+-00ADD8.svg)
![TypeScript](https://img.shields.io/badge/TypeScript-5.8-3178c6.svg)
![Status](https://img.shields.io/badge/status-not%20maintained-lightgrey.svg)

**An interactive Arabic quiz game platform with multiple categories, team battles, lifelines, and a fortune wheel.**

</div>

> **Project status:** Built in 2025 as a full-stack portfolio project (Vue 3 SPA + Go API).
> It is no longer actively maintained and the public demo is offline, but the codebase
> remains a complete, runnable reference — follow the [Quick Start](#-quick-start) to run it locally.

---

## 📋 Overview

**سين جيم** is a team-based Arabic trivia game. Two teams compete across a board of
categories and difficulty tiers, using lifelines and a fortune wheel to outscore each
other. A Go backend handles authentication and per-user question tracking so the same
question is never served twice.

---

## ✨ Features

- **13+ categories** — Flags, Game of Thrones, One Piece, Attack on Titan, Football &
  Premier League, UEFA Champions League, Islamic knowledge, General knowledge, Picture
  challenges, Who Am I?, Proverbs, and more.
- **Team battle mode** with scoring and strategy.
- **Lifelines** — Fortune Wheel, Ask a Friend, 50/50, and Extra Time.
- **Fortune Wheel outcomes** — gain points, double the value, lose your points, or
  deduct from the opponent.
- **Smart question tracking** — per-user history prevents repeats.
- **Difficulty tiers** — 200 / 400 / 600 points per category.
- **Google OAuth 2.0** and email/password auth with secure HttpOnly cookie sessions,
  rate limiting, and CSRF protection.
- **Responsive, RTL-aware UI** built for Arabic.

---

## 🛠️ Tech Stack

| Layer    | Technologies                                                              |
| -------- | ------------------------------------------------------------------------- |
| Frontend | Vue 3.5, TypeScript 5.8, Vite 7, Pinia, Vue Router, Tailwind CSS 4        |
| Backend  | Go 1.22+, Gin, GORM, OAuth2, Bcrypt                                        |
| Database | SQLite (development) · PostgreSQL (production)                             |

---

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm
- Go 1.22+
- Git

### 1. Clone

```bash
git clone https://github.com/mohannad-tawaijri/sen-gem.git
cd sen-gem
```

### 2. Frontend

```bash
cd sinjeem-game
npm install
cp .env.example .env        # set VITE_API_URL if needed
npm run dev                 # http://localhost:5173
```

### 3. Backend

```bash
cd server
go mod tidy
cp .env.example .env        # fill in the values below
go run .                    # http://localhost:8080
```

---

## 🔐 Environment Variables

> Never commit a real `.env`. Only the `*.env.example` templates are tracked.
> Generate a strong session secret, e.g. `openssl rand -base64 32`.

### Backend (`server/.env`)

| Variable               | Default                                          | Description                              |
| ---------------------- | ------------------------------------------------ | ---------------------------------------- |
| `APP_ENV`              | `development`                                     | `development` or `production`            |
| `PORT`                 | `8080`                                            | API port                                 |
| `FRONTEND_ORIGIN`      | `http://localhost:5173`                           | Allowed CORS origin                      |
| `DATABASE_URL`         | `file:server.db`                                  | SQLite file or Postgres DSN              |
| `SESSION_SECRET`       | —                                                 | **Required in prod.** 32+ random chars   |
| `QUESTIONS_DIR`        | `../sinjeem-game/public/questions`                | Path to question JSON files              |
| `GOOGLE_CLIENT_ID`     | —                                                 | Optional, for Google OAuth              |
| `GOOGLE_CLIENT_SECRET` | —                                                 | Optional, for Google OAuth              |
| `OAUTH_REDIRECT_URL`   | `http://localhost:8080/auth/google/callback`      | Must match Google Cloud settings        |
| `AFTER_LOGIN_REDIRECT` | `http://localhost:5173/#/`                        | Where to land after login               |

### Frontend (`sinjeem-game/.env`)

| Variable       | Description                          |
| -------------- | ------------------------------------ |
| `VITE_API_URL` | Base URL of the backend API          |

### Google OAuth setup (optional)

1. Open the [Google Cloud Console](https://console.cloud.google.com).
2. Create a project and OAuth 2.0 credentials.
3. Add the redirect URI: `http://localhost:8080/auth/google/callback`.
4. Copy the Client ID and Secret into `server/.env`.

---

## 📁 Project Structure

```
sen-gem/
├── sinjeem-game/            # Frontend (Vue 3 + Vite)
│   ├── src/                 # components, stores, services, types
│   └── public/
│       ├── questions/       # Question JSON files
│       └── media/           # Category images & assets
├── server/                  # Backend (Go + Gin)
│   ├── auth/                # OAuth, password, sessions, rate limiting
│   ├── config/              # Env configuration
│   ├── db/                  # Database connection
│   ├── models/              # Data models
│   └── questions/           # Question loading & serving
├── pics/                    # Screenshots
├── Dockerfile               # Container build
└── render.yaml              # Render.com blueprint
```

---

## 🔌 API Reference

### Authentication

```
GET  /auth/google/login       Initiate Google OAuth
GET  /auth/google/callback    OAuth callback
GET  /auth/me                 Current user
POST /auth/logout             Log out
POST /auth/register           Register (email/password)
POST /auth/login              Log in (email/password)
```

### Questions

```
GET  /questions/next      ?category=onepiece&difficulty=400   Next unseen question
POST /questions/reset     ?category=football&difficulty=600   Reset seen questions
GET  /questions/preview   ?category=got&difficulty=200&limit=5  Preview questions
GET  /health                                                  Health check
```

### Question JSON format

```json
{
  "id": "onepiece-200-001",
  "difficulty": 200,
  "q": "What is Luffy's dream?",
  "a": "To become Pirate King",
  "tags": ["onepiece", "main_character", "dreams"]
}
```

### Adding a category

1. Create `sinjeem-game/public/questions/<category>.json`.
2. Register it in `sinjeem-game/public/questions/categories.json`.
3. Add an image to `sinjeem-game/public/media/categories/<category>.png`.
4. Add the canonical name to the maps in `server/questions/service.go`.

---

## 🐳 Deployment

### Docker

```bash
docker build -t sin-jeem .
docker run -d -p 8080:8080 \
  -e APP_ENV=production \
  -e SESSION_SECRET="$(openssl rand -base64 32)" \
  -e FRONTEND_ORIGIN=https://yourdomain.com \
  -e DATABASE_URL="postgres://user:pass@host:5432/sengem?sslmode=require" \
  sin-jeem
```

### Render.com

The repo ships a `render.yaml` blueprint. Connect the GitHub repo as a **Blueprint**
in the Render dashboard and set the secret environment variables there.

### Production checklist

- Always serve over HTTPS; cookies are `Secure` when `APP_ENV=production`.
- Set a strong, unique `SESSION_SECRET` — never use the dev default.
- Set `FRONTEND_ORIGIN` to your exact public URL (no trailing slash, no `*`).
- Use PostgreSQL with SSL and strong credentials; back it up regularly.
- Keep all secrets in environment variables / a secret manager — never in git.

---

## 🤝 Contributing

1. Fork and create a feature branch.
2. Follow the existing code style; type all new frontend code.
3. Test your changes and update docs as needed.
4. Open a pull request with a clear description.

---

## 👨‍💻 Author

**Mohannad Tawaijri** · [@mohannad-tawaijri](https://github.com/mohannad-tawaijri) · mohannad.altawaijri@gmail.com

<div align="center">

**Made with ❤️ for Arabic quiz enthusiasts**

</div>
