import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "characterCount", "submitButton"]
  
  connect() {
    console.log("PostFormController connected!")
    this.updateCharacterCount()
  }
  
  contentChanged() {
    this.updateCharacterCount()
  }
  
  updateCharacterCount() {
    if (this.hasContentTarget && this.hasCharacterCountTarget) {
      const count = this.contentTarget.value.length
      this.characterCountTarget.textContent = `${count} characters`
    }
  }
  
  async generateWithAI(event) {
    console.log("generateWithAI called!")
    event.preventDefault()
    
    const content = this.contentTarget.value.trim()
    if (!content) {
      alert("Please enter a topic or prompt for AI generation")
      return
    }
    
    // Show loading state
    const button = event.target
    const originalText = button.textContent
    button.textContent = "✨ Generating..."
    button.disabled = true
    
    try {
      const response = await fetch('/ai/generate_post', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          prompt: content,
          platform: this.getPlatform()
        })
      })
      
      const result = await response.json()
      
      if (result.success) {
        this.contentTarget.value = result.content
        this.updateCharacterCount()
      } else {
        alert(`AI generation failed: ${result.error}`)
      }
    } catch (error) {
      console.error('AI generation error:', error)
      alert('AI generation failed. Please try again.')
    } finally {
      // Reset button state
      button.textContent = originalText
      button.disabled = false
    }
  }
  
  async optimizeContent(event) {
    event.preventDefault()
    
    const content = this.contentTarget.value.trim()
    if (!content) {
      alert("Please enter content to optimize")
      return
    }
    
    // Show loading state
    const button = event.target
    const originalText = button.textContent
    button.textContent = "🎯 Optimizing..."
    button.disabled = true
    
    try {
      const response = await fetch('/ai/optimize_content', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          content: content,
          platform: this.getPlatform()
        })
      })
      
      const result = await response.json()
      
      if (result.success) {
        this.contentTarget.value = result.content
        this.updateCharacterCount()
      } else {
        alert(`Content optimization failed: ${result.error}`)
      }
    } catch (error) {
      console.error('Content optimization error:', error)
      alert('Content optimization failed. Please try again.')
    } finally {
      // Reset button state
      button.textContent = originalText
      button.disabled = false
    }
  }
  
  async autoGeneratePost(event) {
    event.preventDefault()
    
    // Show loading state
    const button = event.target
    const originalText = button.textContent
    button.textContent = "🤖 Auto-Generating..."
    button.disabled = true
    
    try {
      const response = await fetch('/ai/generate_post', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          platform: this.getPlatform()
          // No prompt - will auto-generate topic based on content mode and profile
        })
      })
      
      const result = await response.json()
      
      if (result.success) {
        this.contentTarget.value = result.content
        this.updateCharacterCount()
      } else {
        alert(`Auto-generation failed: ${result.error}`)
      }
    } catch (error) {
      console.error('Auto-generation error:', error)
      alert('Auto-generation failed. Please try again.')
    } finally {
      // Reset button state
      button.textContent = originalText
      button.disabled = false
    }
  }

  getPlatform() {
    // Get selected platform from checkboxes or form
    const platformCheckboxes = document.querySelectorAll('input[name="post[platforms][]"]:checked')
    if (platformCheckboxes.length > 0) {
      return platformCheckboxes[0].value
    }
    return 'linkedin' // Default
  }
}