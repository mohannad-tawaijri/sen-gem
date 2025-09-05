import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { createRouter, createWebHashHistory } from 'vue-router'
import './style.css'
import 'flowbite'
import App from './App.vue'

// Import components
import HomePage from './views/HomePage.vue'
import SetupView from './views/SetupView.vue'
import BoardView from './views/BoardView.vue'
import QuestionView from './views/QuestionView.vue'
import AnswerView from './views/AnswerView.vue'
import ResultsView from './views/ResultsView.vue'
import QrRevealView from './views/QrRevealView.vue'
import AuthCallback from './views/AuthCallback.vue'
import AuthView from './views/AuthView.vue'

const routes = [
  { path: '/', name: 'Home', component: HomePage },
  { path: '/setup', name: 'setup', component: SetupView },
  { path: '/board', name: 'board', component: BoardView },
  { path: '/q', name: 'question', component: QuestionView },
  { path: '/answer', name: 'answer', component: AnswerView },
  { path: '/results', name: 'results', component: ResultsView },
  // Minimal route for mobile reveal page; uses hash to carry secret
  { path: '/reveal', name: 'reveal', component: QrRevealView },
  { path: '/question', redirect: '/q' },
  { path: '/auth/callback', name: 'authcb', component: AuthCallback },
  { path: '/auth', name: 'auth', component: AuthView },
  { path: '/auth/login', redirect: (to: any) => ({ path: '/auth', query: { ...to.query, mode: 'login' } }) },
  { path: '/auth/signup', redirect: (to: any) => ({ path: '/auth', query: { ...to.query, mode: 'signup' } }) },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
})

const pinia = createPinia()

createApp(App)
  .use(router)
  .use(pinia)
  .mount('#app')
