import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "form"]
  
  connect() {
    console.log("Toggle controller connected!")
  }
  
  toggle(event) {
    // Auto-submit form when toggle is clicked
    if (this.hasFormTarget) {
      // Add a small delay to allow the toggle animation to complete
      setTimeout(() => {
        this.formTarget.requestSubmit()
      }, 150)
    }
  }
}