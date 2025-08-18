# Game of Thrones Questions - Complete Rebalancing Summary

## What was changed:
The Game of Thrones section has been completely overhauled with new questions, proper local images, and rebalanced difficulties.

### Before:
- Level 200: 2 questions (very limited content)
- Level 400: 2 questions
- Level 600: 2 questions
- **Total: 6 questions** (using external images from Unsplash)

### After:
- Level 200: 12 questions (Easy)
- Level 400: 15 questions (Medium)  
- Level 600: 15 questions (Hard)
- **Total: 42 questions** (using local images)

## Level Guidelines:

### Level 200 (Easy) - 12 questions
Basic Game of Thrones knowledge that most viewers should know:
- Main houses and their symbols (Stark, Lannister, Baratheon)
- Famous quotes ("Winter is Coming")
- Main characters (Jon Snow, Ned Stark, Cersei, Daenerys)
- Basic locations (King's Landing, The Wall, Iron Throne)
- Dragons' names and basic weapons (Longclaw)

### Level 400 (Medium) - 15 questions
Intermediate knowledge for dedicated fans:
- Supporting characters (Tyrion, Night King, The Hound)
- Organizations (Faceless Men, Iron Bank, Unsullied)
- Cities and geography (Pentos, Essos, Winterfell)
- Religions and gods (R'hllor, Many-Faced God)
- Weapons and materials (Valyrian Steel, Ice sword)
- Poisons and magic elements

### Level 600 (Hard) - 15 questions
Advanced lore for true Game of Thrones experts:
- Ancient history (Old Valyria, Aegon the Conqueror)
- Detailed prophecies (Azor Ahai)
- Specific battles (Whispering Woods, Robert's Rebellion)
- Obscure characters (Maester Aemon, Balerion the dragon)
- Detailed geography (Iron Islands, Riverrun, Lys)
- Complex lore (Drowned God, Great Chain, White Book)

## Image Management:
- **42 new placeholder images** created for all questions
- All images now use **local paths**: `./media/questions/got/[image_name].png`
- **No external dependencies** - images will load locally
- Organized image naming for easy identification

## Content Categories:
Questions are tagged by topic for better organization:
- **houses** - Noble houses and their symbols
- **characters** - Main and supporting characters  
- **locations** - Cities, castles, and geography
- **weapons** - Swords, materials, and tools
- **religion** - Gods, prophecies, and beliefs
- **history** - Past events and ancient lore
- **battles** - Major conflicts and wars

## Files created/modified:
- `got.json` - Updated with 42 comprehensive questions
- `got_original_backup.json` - Backup of original 6 questions
- `got_new.json` - Development version (can be deleted)
- **42 image files** in `/public/media/questions/got/`

## Benefits:
1. **7x more content** (6 → 42 questions)
2. **Better difficulty progression** - truly challenging 600-level questions
3. **Local image hosting** - no external dependencies
4. **Comprehensive coverage** - all major GOT topics included
5. **Better game experience** - more variety and proper challenge levels

The Game of Thrones section is now a comprehensive quiz covering beginner to expert-level knowledge!
