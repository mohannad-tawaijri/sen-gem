# 🚀 Production Deployment Guide

This guide covers deploying the Sinjeem Game in production environments.

## 📦 Repository Structure

The repository contains:
- **Frontend**: `sinjeem-game/` - Vue 3 + Vite SPA
- **Backend**: `server/` - Go + Gin REST API
- **Questions**: `sinjeem-game/public/questions/` - JSON question files

---

## 🐳 Docker Deployment (Recommended)

### Prerequisites
- Docker 24+ and Docker Compose
- 2GB RAM minimum
- Linux/Windows/macOS

### Option 1: Single Container

**Build the image:**
```bash
docker build -t sinjeem:latest .
```

**Run with SQLite (development):**
```bash
docker run -d \
  --name sinjeem-game \
  -p 8080:8080 \
  -e APP_ENV=production \
  -e SESSION_SECRET=your-strong-secret-key \
  -e FRONTEND_ORIGIN=https://yourdomain.com \
  sinjeem:latest
```

**Run with PostgreSQL (production):**
```bash
docker run -d \
  --name sinjeem-game \
  -p 8080:8080 \
  -e APP_ENV=production \
  -e DATABASE_URL="postgres://user:password@host:5432/sinjeem?sslmode=require" \
  -e SESSION_SECRET=your-strong-secret-key \
  -e FRONTEND_ORIGIN=https://yourdomain.com \
  -e GOOGLE_CLIENT_ID=your-google-client-id \
  -e GOOGLE_CLIENT_SECRET=your-google-client-secret \
  sinjeem:latest
```

**Custom questions directory:**
```bash
docker run -d \
  --name sinjeem-game \
  -p 8080:8080 \
  -v /path/to/questions:/app/questions \
  -e QUESTIONS_DIR=/app/questions \
  sinjeem:latest
```

### Option 2: Docker Compose

Create `docker-compose.prod.yml`:
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      APP_ENV: production
      DATABASE_URL: postgres://sinjeem:password@db:5432/sinjeem
      SESSION_SECRET: ${SESSION_SECRET}
      FRONTEND_ORIGIN: ${FRONTEND_ORIGIN}
      GOOGLE_CLIENT_ID: ${GOOGLE_CLIENT_ID}
      GOOGLE_CLIENT_SECRET: ${GOOGLE_CLIENT_SECRET}
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: sinjeem
      POSTGRES_USER: sinjeem
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  postgres_data:
```

**Deploy:**
```bash
# Create .env file with secrets
echo "SESSION_SECRET=$(openssl rand -base64 32)" > .env
echo "DB_PASSWORD=$(openssl rand -base64 32)" >> .env
echo "FRONTEND_ORIGIN=https://yourdomain.com" >> .env

# Start services
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f
```

---

## ☁️ Render.com Deployment

### Automatic Deployment

The repository includes `render.yaml` for one-click deployment.

**Steps:**
1. Push code to GitHub
2. Go to [Render Dashboard](https://dashboard.render.com/)
3. Click "New" → "Blueprint"
4. Connect your GitHub repo
5. Render will auto-configure using `render.yaml`

### Manual Configuration

**Web Service:**
- **Name**: sinjeem-game
- **Environment**: Docker
- **Region**: Choose closest to users
- **Plan**: Starter ($7/month) or higher
- **Build Command**: (handled by Dockerfile)
- **Start Command**: (handled by Dockerfile)

**Environment Variables:**
```
APP_ENV=production
DATABASE_URL=<postgres-connection-string>
SESSION_SECRET=<generate-random-secret>
FRONTEND_ORIGIN=https://your-app.onrender.com
GOOGLE_CLIENT_ID=<optional>
GOOGLE_CLIENT_SECRET=<optional>
```

**PostgreSQL Database:**
- Create a new PostgreSQL instance on Render
- Copy the "Internal Database URL"
- Set as `DATABASE_URL` in web service

---

## 🔧 Manual Deployment

### Prerequisites
```bash
- Node.js 18+
- Go 1.21+
- PostgreSQL 14+
- Nginx (optional, for reverse proxy)
```

### Build Frontend

```bash
cd sinjeem-game
npm install
npm run build
# Output in dist/
```

### Build Backend

```bash
cd server
go mod download
go build -o sinjeem-server main.go
```

### Deploy

**1. Copy files to server:**
```bash
scp -r sinjeem-game/dist/ user@server:/var/www/sinjeem/
scp server/sinjeem-server user@server:/opt/sinjeem/
scp -r sinjeem-game/public/questions/ user@server:/opt/sinjeem/questions/
```

**2. Create systemd service (`/etc/systemd/system/sinjeem.service`):**
```ini
[Unit]
Description=Sinjeem Game Server
After=network.target postgresql.service

[Service]
Type=simple
User=www-data
WorkingDir=/opt/sinjeem
ExecStart=/opt/sinjeem/sinjeem-server
Restart=always
RestartSec=10

Environment="APP_ENV=production"
Environment="PORT=8080"
Environment="DATABASE_URL=postgres://user:pass@localhost:5432/sinjeem"
Environment="SESSION_SECRET=your-secret"
Environment="FRONTEND_DIR=/var/www/sinjeem"
Environment="QUESTIONS_DIR=/opt/sinjeem/questions"
Environment="FRONTEND_ORIGIN=https://yourdomain.com"

[Install]
WantedBy=multi-user.target
```

**3. Start service:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable sinjeem
sudo systemctl start sinjeem
```

**4. Configure Nginx (optional):**
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # API requests
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Frontend
    location / {
        root /var/www/sinjeem;
        try_files $uri $uri/ /index.html;
        expires 1d;
        add_header Cache-Control "public, immutable";
    }
}
```

---

## 🔐 Security Considerations

### Essential Security Steps

1. **Generate Strong Secrets:**
   ```bash
   # Session secret
   openssl rand -base64 32
   
   # Database password
   openssl rand -base64 32
   ```

2. **Use HTTPS:**
   - Always use SSL/TLS in production
   - Use Let's Encrypt for free certificates
   - Set `FRONTEND_ORIGIN` to https://

3. **Database Security:**
   - Use strong passwords
   - Enable SSL mode for PostgreSQL connections
   - Restrict database access by IP
   - Regular backups

4. **Environment Variables:**
   - Never commit secrets to git
   - Use `.env` files (add to .gitignore)
   - Use secret management in cloud (AWS Secrets Manager, etc.)

5. **Rate Limiting:**
   - Backend has built-in rate limiting
   - Consider adding Cloudflare or AWS WAF

6. **CORS Configuration:**
   - Set `FRONTEND_ORIGIN` correctly
   - Don't use `*` in production

---

## 📊 Monitoring & Maintenance

### Health Checks

**Backend health endpoint:**
```bash
curl http://localhost:8080/api/health
```

**Response:**
```json
{
  "status": "ok",
  "database": "connected"
}
```

### Logs

**Docker:**
```bash
docker logs -f sinjeem-game
```

**Systemd:**
```bash
journalctl -u sinjeem -f
```

### Database Backups

**PostgreSQL backup:**
```bash
# Backup
pg_dump -h localhost -U sinjeem -d sinjeem > backup_$(date +%Y%m%d).sql

# Restore
psql -h localhost -U sinjeem -d sinjeem < backup_20250125.sql
```

**Automated daily backups (cron):**
```bash
0 2 * * * pg_dump -h localhost -U sinjeem -d sinjeem | gzip > /backups/sinjeem_$(date +\%Y\%m\%d).sql.gz
```

### Updates

**Docker:**
```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
```

**Manual:**
```bash
# Pull latest
git pull origin main

# Rebuild frontend
cd sinjeem-game && npm install && npm run build

# Rebuild backend
cd ../server && go build -o sinjeem-server main.go

# Restart service
sudo systemctl restart sinjeem
```

---

## 🐛 Troubleshooting

### Common Issues

**1. Port already in use:**
```bash
# Find process
lsof -i :8080
# Kill it
kill -9 <PID>
```

**2. Database connection failed:**
- Check `DATABASE_URL` format
- Verify PostgreSQL is running
- Check network connectivity
- Verify credentials

**3. CORS errors:**
- Ensure `FRONTEND_ORIGIN` matches your domain
- Include protocol (https://)
- No trailing slash

**4. Questions not loading:**
- Check `QUESTIONS_DIR` path
- Verify JSON files exist
- Check file permissions

**5. Google OAuth not working:**
- Verify `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`
- Add authorized redirect URIs in Google Console:
  - `https://yourdomain.com/api/auth/google/callback`
- Add authorized JavaScript origins:
  - `https://yourdomain.com`

---

## 📞 Support

For deployment issues:
1. Check [GitHub Issues](https://github.com/mohannad-tawaijri/sen-gem/issues)
2. Review logs carefully
3. Create a new issue with:
   - Deployment method
   - Error messages
   - Environment details

---

## 🎯 Performance Tips

1. **Enable compression** (Nginx gzip)
2. **Use CDN** for static assets
3. **Database indexes** (already configured)
4. **Connection pooling** (GORM handles this)
5. **Horizontal scaling** (deploy multiple instances behind load balancer)

---

**Happy deploying! 🚀**

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
