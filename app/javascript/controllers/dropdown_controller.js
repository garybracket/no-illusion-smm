import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  static classes = ["hidden"]
  
  connect() {
    // Close dropdown when clicking outside
    document.addEventListener('click', this.closeOnOutsideClick.bind(this))
  }
  
  disconnect() {
    document.removeEventListener('click', this.closeOnOutsideClick.bind(this))
  }
  
  toggle(event) {
    event.stopPropagation()
    
    if (this.menuTarget.classList.contains('hidden')) {
      this.open()
    } else {
      this.close()
    }
  }
  
  open() {
    this.menuTarget.classList.remove('hidden')
  }
  
  close() {
    this.menuTarget.classList.add('hidden')
  }
  
  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}