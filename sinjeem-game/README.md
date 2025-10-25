# 🎮 Sen-Gem Frontend

Vue 3 + TypeScript quiz game frontend application.

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## 📦 Available Scripts

### Question Management
```bash
# Sync Champions League question difficulties
npm run sync:ucl

# Extract images from PDF files
npm run extract:pictures

# Generate pictures map from images
npm run pictures:map

# Build pictures from map
npm run pictures:build

# Run all picture processing steps
npm run pictures:all
```

## 🛠️ Tech Stack

- **Vue 3.5** - Composition API with `<script setup>`
- **TypeScript 5.8** - Type safety
- **Vite 7.0** - Fast build tool
- **Tailwind CSS 4** - Styling
- **Pinia** - State management
- **Vue Router** - Routing

## 📂 Project Structure

```
src/
├── components/        # Vue components
│   ├── GameBoard.vue
│   ├── QuestionCard.vue
│   ├── RouletteModal.vue
│   └── ...
├── stores/           # Pinia stores
│   └── session.ts
├── services/         # API services
│   └── questions.ts
├── types/            # TypeScript definitions
└── App.vue           # Root component

public/
├── questions/        # Question JSON files
│   ├── onepiece.json
│   ├── aot.json
│   └── ...
└── media/           # Images and assets
```

## 🔧 Configuration

Create a `.env` file:

```env
VITE_API_URL=http://localhost:8080
```

## 📖 Component Documentation

### Key Components

- **GameBoard.vue** - Main game interface
- **QuestionCard.vue** - Question display and answer input
- **RouletteModal.vue** - Fortune wheel component (SVG-based)
- **LifelineBar.vue** - Lifeline buttons and management
- **TimerOverlay.vue** - Question timer display

### State Management (Pinia)

The `session` store manages:
- Current game state
- Team scores and lifelines
- Question tracking
- Fortune wheel outcomes

## 🎨 Styling

The project uses Tailwind CSS 4 with custom configurations:
- RTL (Right-to-Left) support for Arabic
- Custom color schemes
- Responsive design utilities
- Dark mode support

## 📝 Adding New Questions

1. Create a JSON file in `public/questions/category.json`
2. Follow the question schema:
   ```json
   {
     "id": "category-difficulty-number",
     "difficulty": 200 | 400 | 600,
     "q": "Question text",
     "a": "Answer text",
     "tags": ["category", "tag1", "tag2"]
   }
   ```
3. Add category to `public/questions/categories.json`
4. Add category image to `public/media/categories/`

## 🐛 Troubleshooting

### Build Issues
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Type Errors
```bash
# Regenerate TypeScript definitions
npm run build -- --force
```

## 📄 License

MIT License - see root README.md for details
