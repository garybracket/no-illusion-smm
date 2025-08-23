// Simple theme toggle without Stimulus + Mobile Dropdown
document.addEventListener('DOMContentLoaded', function() {
  console.log('Theme script loaded!')
  
  // Initialize theme on page load
  initializeTheme()
  
  // Add click listeners to ALL theme toggle buttons (desktop and mobile)
  const themeButtons = document.querySelectorAll('[data-theme-toggle]')
  themeButtons.forEach(button => {
    console.log('Theme button found, adding listener')
    button.addEventListener('click', function(e) {
      e.preventDefault()
      toggleTheme()
    })
  })
  
  // Mobile dropdown functionality
  const mobileMenuButton = document.getElementById('mobile-menu-button')
  const mobileMenuDropdown = document.getElementById('mobile-menu-dropdown')
  
  if (mobileMenuButton && mobileMenuDropdown) {
    console.log('Mobile menu found, adding listeners')
    
    mobileMenuButton.addEventListener('click', function(e) {
      e.preventDefault()
      e.stopPropagation()
      
      if (mobileMenuDropdown.classList.contains('hidden')) {
        mobileMenuDropdown.classList.remove('hidden')
      } else {
        mobileMenuDropdown.classList.add('hidden')
      }
    })
    
    // Close dropdown when clicking outside
    document.addEventListener('click', function(e) {
      if (!mobileMenuButton.contains(e.target) && !mobileMenuDropdown.contains(e.target)) {
        mobileMenuDropdown.classList.add('hidden')
      }
    })
    
    // Close dropdown when clicking a link
    const dropdownLinks = mobileMenuDropdown.querySelectorAll('a')
    dropdownLinks.forEach(link => {
      link.addEventListener('click', function() {
        mobileMenuDropdown.classList.add('hidden')
      })
    })
  }
})

function initializeTheme() {
  const savedTheme = localStorage.getItem('theme') || 'light'
  console.log(`Initializing theme: ${savedTheme}`)
  setTheme(savedTheme)
}

function toggleTheme() {
  const currentTheme = localStorage.getItem('theme') || 'light'
  const newTheme = currentTheme === 'light' ? 'dark' : 'light'
  console.log(`Toggling from ${currentTheme} to ${newTheme}`)
  setTheme(newTheme)
}

function setTheme(theme) {
  console.log(`Setting theme to: ${theme}`)
  localStorage.setItem('theme', theme)
  
  const html = document.documentElement
  const buttons = document.querySelectorAll('[data-theme-toggle]')
  
  if (theme === 'dark') {
    html.classList.add('dark')
    buttons.forEach(button => {
      button.classList.remove('bg-gray-200', 'text-gray-800')
      button.classList.add('bg-gray-700', 'text-gray-200')
      const iconContainer = button.querySelector('span')
      if (iconContainer) {
        iconContainer.innerHTML = moonIcon()
      }
    })
    console.log('Applied dark theme')
  } else {
    html.classList.remove('dark')
    buttons.forEach(button => {
      button.classList.remove('bg-gray-700', 'text-gray-200')
      button.classList.add('bg-gray-200', 'text-gray-800')
      const iconContainer = button.querySelector('span')
      if (iconContainer) {
        iconContainer.innerHTML = sunIcon()
      }
    })
    console.log('Applied light theme')
  }
  
  console.log(`HTML dark class: ${html.classList.contains('dark')}`)
}

function sunIcon() {
  return `
    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
    </svg>
  `
}

function moonIcon() {
  return `
    <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
    </svg>
  `
}