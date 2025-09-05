// Minimal API wrapper using fetch with credentials
export type User = {
  id: number
  email: string
  username?: string
  name: string
  picture?: string
  verified?: boolean
}

export async function me() {
  const res = await fetch('/api/me', { credentials: 'include' })
  if (!res.ok) throw new Error('me failed')
  return res.json()
}

export async function logout() {
  const res = await fetch('/api/auth/logout', { method: 'POST', credentials: 'include' })
  if (!res.ok) throw new Error('logout failed')
}

export function googleLogin(next?: string) {
  const url = new URL('/auth/google/login', window.location.origin)
  const nextParam = next || (window.location.hash?.startsWith('#/') ? window.location.hash.substring(1) : '/')
  // Absolute redirect to the frontend origin to avoid landing on :8080
  const redirect = `${window.location.origin}/#/auth/callback?next=${encodeURIComponent(nextParam)}`
  url.searchParams.set('redirect', redirect)
  window.location.href = url.toString()
}

export async function login(identifier: { email?: string; username?: string }, password: string) {
  const res = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
  body: JSON.stringify({ ...identifier, password }),
  })
  if (!res.ok) throw new Error('login failed')
  return res.json()
}

export async function signup(email: string, username: string, password: string, name?: string) {
  const res = await fetch('/api/auth/signup', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
  body: JSON.stringify({ email, username, password, name }),
  })
  if (!res.ok) throw new Error('signup failed')
  return res.json()
}

export async function nextQuestion(params: { category?: string; difficulty?: number } = {}) {
  const url = new URL('/api/questions/next', window.location.origin)
  if (params.category) url.searchParams.set('category', params.category)
  if (params.difficulty) url.searchParams.set('difficulty', String(params.difficulty))
  const res = await fetch(url.toString(), { credentials: 'include' })
  if (!res.ok) throw new Error('next failed')
  return res.json()
}

export async function stats(params: { category?: string; difficulty?: number } = {}) {
  const url = new URL('/api/questions/stats', window.location.origin)
  if (params.category) url.searchParams.set('category', params.category)
  if (params.difficulty) url.searchParams.set('difficulty', String(params.difficulty))
  const res = await fetch(url.toString(), { credentials: 'include' })
  if (!res.ok) throw new Error('stats failed')
  return res.json()
}

export async function resetSeen(params: { category?: string; difficulty?: number } = {}) {
  const url = new URL('/api/questions/reset', window.location.origin)
  if (params.category) url.searchParams.set('category', params.category)
  if (params.difficulty) url.searchParams.set('difficulty', String(params.difficulty))
  const res = await fetch(url.toString(), { method: 'POST', credentials: 'include' })
  if (!res.ok) throw new Error('reset failed')
}

export async function markSeen(id: string) {
  const res = await fetch('/api/questions/seen', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify({ id }),
  })
  if (!res.ok) throw new Error('markSeen failed')
  return res.json()
}
