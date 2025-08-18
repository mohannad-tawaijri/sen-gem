# Local flags images kit (flagcdn.com → PNG w512)

1) فك الضغط في جذر المشروع (سيُنشئ مجلدات: scripts/, manifest/).
2) نزّل الأعلام محليًا:
   ```bash
   node scripts/download_flagcdn.mjs
   ```
   ستحفظ الصور إلى: `public/media/questions/flags/<code>.png`

3) تحقّق من اكتمال الصور:
   ```bash
   node scripts/verify_flags.mjs
   ```

> الملف `questions.flags.v200.local.json` (من الحزمة الأخرى) يشير لمسارات **محليّة** فقط، ولن نعدّل ملفك `public/questions.all.json`.
> إذا أردت دمج الفئة: افتح ملف الأسئلة عندك وأدمج محتوى فئة "flags" من هذا الملف يدويًا أو عبر سكربتك الخاص.
