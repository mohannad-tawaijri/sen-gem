## Multi-stage build: build frontend (Vite) and backend (Go)

# 1) Build frontend
FROM node:20-alpine AS web
WORKDIR /work
COPY sinjeem-game/package.json sinjeem-game/package-lock.json* ./sinjeem-game/
WORKDIR /work/sinjeem-game
RUN npm ci || npm install
COPY sinjeem-game/ /work/sinjeem-game/
RUN npm run build

# 2) Build backend
FROM golang:1.23-alpine AS server
WORKDIR /app
COPY server/go.mod server/go.sum* ./server/
WORKDIR /app/server
RUN go mod download
COPY server/ /app/server/
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/sengem-server .

# 3) Runtime image
FROM alpine:3.20
WORKDIR /app

# Copy server binary and web assets
COPY --from=server /app/sengem-server /app/sengem-server
COPY --from=web /work/sinjeem-game/dist/ /app/web/

# Copy questions data (public/questions) into image by default
COPY sinjeem-game/public/questions/ /app/questions/

EXPOSE 8080
CMD ["/app/sengem-server"]
