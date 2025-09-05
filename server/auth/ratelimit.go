package auth

import (
	"net"
	"net/http"
	"sync"
	"time"
)

type limiterEntry struct {
	count     int
	resetAt   time.Time
	lockedTil time.Time
}

type RateLimiter struct {
	mu               sync.Mutex
	byKey            map[string]*limiterEntry
	window           time.Duration
	limit            int
	lockoutThreshold int
	lockoutDuration  time.Duration
}

func NewRateLimiter(window time.Duration, limit int, lockoutThreshold int, lockoutDuration time.Duration) *RateLimiter {
	return &RateLimiter{byKey: map[string]*limiterEntry{}, window: window, limit: limit, lockoutThreshold: lockoutThreshold, lockoutDuration: lockoutDuration}
}

func clientIP(r *http.Request) string {
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	return host
}

func (rl *RateLimiter) keyFor(r *http.Request, extra string) string {
	return clientIP(r) + "|" + extra
}

// Allow increments count and returns whether the request is allowed and whether locked
func (rl *RateLimiter) Allow(r *http.Request, extra string) (bool, bool, time.Duration) {
	rl.mu.Lock()
	defer rl.mu.Unlock()
	k := rl.keyFor(r, extra)
	now := time.Now()
	e, ok := rl.byKey[k]
	if !ok {
		e = &limiterEntry{count: 0, resetAt: now.Add(rl.window)}
		rl.byKey[k] = e
	}
	if now.Before(e.lockedTil) {
		return false, true, e.lockedTil.Sub(now)
	}
	if now.After(e.resetAt) {
		e.count = 0
		e.resetAt = now.Add(rl.window)
	}
	e.count++
	if e.count > rl.limit {
		return false, false, e.resetAt.Sub(now)
	}
	return true, false, e.resetAt.Sub(now)
}

// Fail increments towards lockout; call this on bad credentials
func (rl *RateLimiter) Fail(r *http.Request, extra string) {
	rl.mu.Lock()
	defer rl.mu.Unlock()
	k := rl.keyFor(r, extra)
	now := time.Now()
	e, ok := rl.byKey[k]
	if !ok {
		e = &limiterEntry{count: 0, resetAt: now.Add(rl.window)}
		rl.byKey[k] = e
	}
	e.count++
	if e.count >= rl.lockoutThreshold {
		e.lockedTil = now.Add(rl.lockoutDuration)
		e.count = 0
		e.resetAt = e.lockedTil.Add(rl.window)
	}
}
