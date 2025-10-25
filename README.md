# 🎮 سنجيم (Sen-Gem) - Arabic Quiz Game Platform

<div align="center">

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Vue](https://img.shields.io/badge/Vue-3.5-green.svg)
![Go](https://img.shields.io/badge/Go-1.22+-00ADD8.svg)
![TypeScript](https://img.shields.io/badge/TypeScript-5.8-blue.svg)

**An interactive Arabic quiz game platform featuring multiple categories, team battles, and smart question management**

[Features](#-features) • [Tech Stack](#-tech-stack) • [Quick Start](#-quick-start) • [Documentation](#-documentation)

</div>

---

## 📋 Overview

Sen-Gem is a comprehensive quiz game platform designed for Arabic-speaking audiences. It features a dynamic question system, team-based gameplay, lifelines, and a fortune wheel mechanic. The platform supports multiple question categories including sports, entertainment, general knowledge, and more.

### 🎯 Key Highlights

- **Multi-Category Quiz System**: 13+ categories including Football, Game of Thrones, One Piece, Attack on Titan, and more
- **Team Battle Mode**: Compete in teams with strategic lifelines and power-ups
- **Smart Question Management**: Never see the same question twice with per-user tracking
- **Fortune Wheel**: Exciting risk/reward mechanic with multiple outcomes
- **Google OAuth Integration**: Secure authentication and user management
- **Difficulty Levels**: Questions categorized into 200, 400, and 600 difficulty tiers
- **Progressive Web App**: Fully responsive design that works on all devices

---

## ✨ Features

### 🎲 Game Mechanics

- **Question Categories**: 
  - 🏴 Flags (Countries)
  - 🎬 Game of Thrones
  - ⚓ One Piece
  - 🗡️ Attack on Titan
  - ⚽ Football & Premier League
  - 🏆 UEFA Champions League
  - 🕌 Islamic Knowledge
  - 🧩 General Knowledge
  - 🖼️ Picture Challenges
  - 🎭 Who Am I?
  - 📝 Saudi Proverbs

- **Lifelines**:
  - 🎰 Fortune Wheel (3 uses per team)
  - 📱 Ask a Friend
  - ✂️ 50/50 (eliminates 2 wrong answers)
  - ⏰ Extra Time

- **Fortune Wheel Outcomes**:
  - ✅ Gain points from current question
  - 💎 Double the question value
  - ❌ Lose all your points
  - 🎯 Deduct points from opponent

### 🔐 User Management

- Google OAuth 2.0 authentication
- Session-based security with HttpOnly cookies
- Per-user question tracking (no repeated questions)
- Progress persistence across sessions
- Rate limiting and CSRF protection

### 📊 Question System

- **30 questions per category** (10 easy, 10 medium, 10 hard)
- **1000+ total questions** across all categories
- Dynamic difficulty selection
- Category filtering
- Question reset functionality
- Alias support for legacy question IDs

---

## 🛠️ Tech Stack

### Frontend (Vue 3 + TypeScript)

```
├── Vue 3.5         - Progressive JavaScript framework
├── TypeScript 5.8  - Type-safe development
├── Vite 7.0        - Lightning-fast build tool
├── Pinia           - State management
├── Vue Router      - Client-side routing
├── Tailwind CSS 4  - Utility-first styling
├── Headless UI     - Accessible components
└── Flowbite        - UI component library
```

### Backend (Go + Gin)

```
├── Go 1.22+        - High-performance backend
├── Gin             - Web framework
├── GORM            - ORM with SQLite/Postgres
├── OAuth2          - Google authentication
└── Bcrypt          - Password hashing
```

### Database

- **Development**: SQLite (embedded)
- **Production**: PostgreSQL (recommended)

---

## 🚀 Quick Start

### Prerequisites

- **Node.js** 18+ and npm/yarn
- **Go** 1.22+
- **Git**

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mohannad-tawaijri/sen-gem.git
   cd sen-gem
   ```

2. **Setup Frontend**
   ```bash
   cd sinjeem-game
   npm install
   cp .env.example .env
   # Edit .env and set VITE_API_URL=http://localhost:8080
   npm run dev
   ```
   Frontend will run on `http://localhost:5173`

3. **Setup Backend**
   ```bash
   cd ../server
   go mod tidy
   cp .env.example .env
   # Edit .env and configure Google OAuth credentials
   go run .
   ```
   Backend will run on `http://localhost:8080`

### Environment Variables

#### Frontend (.env)
```env
VITE_API_URL=http://localhost:8080
```

#### Backend (.env)
```env
PORT=8080
FRONTEND_URL=http://localhost:5173
QUESTIONS_DIR=../sinjeem-game/public/questions

# Google OAuth
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
GOOGLE_REDIRECT_URL=http://localhost:8080/auth/google/callback

# Session
SESSION_SECRET=your-random-secret-key-here

# Database (optional, defaults to SQLite)
# DATABASE_URL=postgres://user:pass@host:5432/dbname
```

### Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URI: `http://localhost:8080/auth/google/callback`
6. Copy Client ID and Secret to `.env`

---

## 📚 Documentation

### Project Structure

```
sen-gem/
├── sinjeem-game/           # Frontend Vue application
│   ├── src/
│   │   ├── components/     # Vue components
│   │   ├── stores/         # Pinia stores
│   │   ├── services/       # API services
│   │   └── types/          # TypeScript types
│   ├── public/
│   │   ├── questions/      # Question JSON files
│   │   └── media/          # Images and assets
│   └── scripts/            # Build and maintenance scripts
│
├── server/                 # Backend Go application
│   ├── auth/              # Authentication handlers
│   ├── config/            # Configuration management
│   ├── db/                # Database connection
│   ├── models/            # Data models
│   └── questions/         # Question service
│
├── pics/                  # Project screenshots
├── Dockerfile            # Docker configuration
├── render.yaml           # Render.com deployment config
└── DEPLOYMENT.md         # Deployment guide
```

### API Endpoints

#### Authentication
```
GET  /auth/google/login       - Initiate Google OAuth
GET  /auth/google/callback    - OAuth callback handler
GET  /auth/me                 - Get current user
POST /auth/logout             - Logout user
POST /auth/register           - Register with email/password
POST /auth/login              - Login with email/password
```

#### Questions
```
GET  /questions/next          - Get next question
     ?category=onepiece       - Filter by category
     &difficulty=400          - Filter by difficulty

POST /questions/reset         - Reset seen questions
     ?category=football       - Reset specific category
     &difficulty=600          - Reset specific difficulty

GET  /questions/preview       - Preview available questions
     ?category=got
     &difficulty=200
     &limit=5
```

#### Health
```
GET  /health                  - Health check endpoint
```

### Question JSON Format

Each category has a JSON file with 30 questions:

```json
[
  {
    "id": "onepiece-200-001",
    "difficulty": 200,
    "q": "What is Luffy's dream?",
    "a": "To become Pirate King",
    "tags": ["onepiece", "main_character", "dreams"]
  }
]
```

### Adding New Categories

1. **Create question file**: `public/questions/mycategory.json`
2. **Add to categories**: Update `public/questions/categories.json`
3. **Add image**: Place image in `public/media/categories/mycategory.png`
4. **Register in backend**: Add to `server/questions/service.go`

```go
// In canonicalCategories map
var canonicalCategories = map[string]struct{}{
    "mycategory": {},
    // ... other categories
}

// In canonByLower map
var canonByLower = map[string]string{
    "mycategory": "mycategory",
    // ... other mappings
}
```

---

## 🐳 Deployment

### Docker

```bash
docker build -t sen-gem .
docker run -p 8080:8080 -e DATABASE_URL="your-db-url" sen-gem
```

### Render.com

The project includes `render.yaml` for easy deployment:

1. Connect your GitHub repository to Render
2. Render will automatically detect the configuration
3. Set environment variables in Render dashboard
4. Deploy!

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions.

---

## 🎨 Screenshots

<details>
<summary>Click to view screenshots</summary>

### Game Board
![Game Board](pics/Screenshot%202025-07-26%20143503.png)

### Question Display
![Question](pics/Screenshot%202025-07-26%20143524.png)

### Fortune Wheel
![Wheel](pics/Screenshot%202025-07-26%20143613.png)

### Categories
![Categories](pics/Screenshot%202025-07-26%20143627.png)

</details>

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow the existing code style
- Add TypeScript types for all new code
- Test your changes thoroughly
- Update documentation as needed
- Write meaningful commit messages

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 Author

**Mohannad Tawaijri**
- GitHub: [@mohannad-tawaijri](https://github.com/mohannad-tawaijri)
- Email: mohannd9926@gmail.com

---

## 🙏 Acknowledgments

- Vue.js team for the amazing framework
- Go and Gin communities
- All contributors and testers
- Arabic quiz community

---

<div align="center">

**Made with ❤️ for Arabic learners and quiz enthusiasts**

[⬆ Back to Top](#-سنجيم-sen-gem---arabic-quiz-game-platform)

</div>
