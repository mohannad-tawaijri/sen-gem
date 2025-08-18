import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { createRouter, createWebHistory } from 'vue-router'
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

const routes = [
  { path: '/', name: 'Home', component: HomePage },
  { path: '/setup', name: 'setup', component: SetupView },
  { path: '/board', name: 'board', component: BoardView },
  { path: '/q', name: 'question', component: QuestionView },
  { path: '/answer', name: 'answer', component: AnswerView },
  { path: '/results', name: 'results', component: ResultsView },
  { path: '/question', redirect: '/q' }, // للتوافق مع الكود القديم
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

const pinia = createPinia()

createApp(App)
  .use(router)
  .use(pinia)
  .mount('#app')
