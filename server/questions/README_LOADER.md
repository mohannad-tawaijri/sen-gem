Loader behavior notes:

- Only JSON files whose basename matches a canonical category slug (flags, got, onepiece, proverbs, football, premierleague, general, noWords, pictures, championsleague, islamic) are loaded.
- Files using alias basenames (e.g., ucl.json) are also accepted and mapped to canonical (championsleague).
- Any other JSON files in the questions folder (e.g., *_no_answers.json, drafts, backups) are ignored by the loader.
- IDs are normalized at load to <slug>-<difficulty>-NNN and legacy IDs are mapped via id_aliases.json if present.
