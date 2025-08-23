import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Theme controller connected!")
    this.initializeTheme()
  }

  toggle(event) {
    event.preventDefault()
    console.log("Toggle clicked!")
    
    const currentTheme = localStorage.getItem('theme') || 'light'
    const newTheme = currentTheme === 'light' ? 'dark' : 'light'
    console.log(`Switching from ${currentTheme} to ${newTheme}`)
    
    this.setTheme(newTheme)
  }

  initializeTheme() {
    const savedTheme = localStorage.getItem('theme') || 'light'
    console.log(`Initializing with theme: ${savedTheme}`)
    this.setTheme(savedTheme)
  }

  setTheme(theme) {
    console.log(`Setting theme to: ${theme}`)
    localStorage.setItem('theme', theme)
    
    const html = document.documentElement
    const button = this.element.querySelector('button')
    const iconContainer = this.element.querySelector('button span')
    
    if (theme === 'dark') {
      html.classList.add('dark')
      if (button) {
        button.classList.remove('bg-gray-200', 'text-gray-800')
        button.classList.add('bg-gray-700', 'text-gray-200')
      }
      if (iconContainer) {
        iconContainer.innerHTML = this.moonIcon()
      }
    } else {
      html.classList.remove('dark')
      if (button) {
        button.classList.remove('bg-gray-700', 'text-gray-200')
        button.classList.add('bg-gray-200', 'text-gray-800')
      }
      if (iconContainer) {
        iconContainer.innerHTML = this.sunIcon()
      }
    }
    
    console.log(`Theme applied: ${theme}, dark class present: ${html.classList.contains('dark')}`)
  }

  sunIcon() {
    return `
      <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
      </svg>
    `
  }

  moonIcon() {
    return `
      <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
      </svg>
    `
  }
}