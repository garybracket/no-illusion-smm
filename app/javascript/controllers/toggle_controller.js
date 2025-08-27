import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "form"]
  
  connect() {
    console.log("=== TOGGLE CONTROLLER CONNECTED ===")
    console.log("Form target found:", this.hasFormTarget)
    console.log("Checkbox target found:", this.hasCheckboxTarget)
    console.log("Form element:", this.hasFormTarget ? this.formTarget : "Not found")
    console.log("Checkbox element:", this.hasCheckboxTarget ? this.checkboxTarget : "Not found")
    console.log("Element:", this.element)
    console.log("All data attributes:", this.element.dataset)
  }
  
  controllerLoaded() {
    console.log("=== CONTROLLER LOADED EVENT FIRED ===")
  }
  
  toggle(event) {
    console.log("Toggle clicked!", event.target.checked)
    console.log("Current checkbox state:", this.checkboxTarget?.checked)
    
    if (this.hasFormTarget) {
      console.log("Submitting form via Stimulus target:", this.formTarget.action)
      
      // Add a small delay to allow the toggle animation to complete
      setTimeout(() => {
        try {
          this.formTarget.requestSubmit()
          console.log("Form submitted successfully via requestSubmit")
        } catch (error) {
          console.error("requestSubmit failed:", error)
          console.log("Falling back to traditional submit...")
          this.formTarget.submit()
        }
      }, 150)
    } else {
      console.error("No form target found! Available targets:", this.targets)
      console.error("Form target should be:", document.querySelector('[data-toggle-form-target]'))
    }
  }
}