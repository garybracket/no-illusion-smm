const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/views/**/*.erb'
  ],
  darkMode: 'class', // Enable class-based dark mode
  safelist: [
    // Force include critical dark mode classes
    'dark:bg-gray-900',
    'dark:bg-gray-800', 
    'dark:bg-gray-700',
    'dark:text-white',
    'dark:text-gray-100',
    'dark:text-gray-200',
    'dark:text-gray-300',
    'dark:border-gray-600',
    'dark:border-gray-700',
    'dark:hover:bg-gray-600',
    'dark:hover:bg-gray-700',
    'dark:hover:text-blue-400',
    'dark:hover:text-blue-300'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}