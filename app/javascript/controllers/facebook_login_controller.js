import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status"]

  connect() {
    console.log("Facebook login controller connected")
    this.checkFacebookSDK()
  }

  checkFacebookSDK() {
    // Wait for Facebook SDK to load
    if (typeof FB !== 'undefined') {
      this.setupButton()
    } else {
      // Check again in 100ms if FB SDK isn't loaded yet
      setTimeout(() => this.checkFacebookSDK(), 100)
    }
  }

  setupButton() {
    console.log("Facebook Business SDK loaded, setting up login")
    this.updateStatus("Facebook Business SDK ready")
    
    // For business apps, skip automatic login status check
    // Business apps need explicit user interaction
    this.updateStatus("Ready for Facebook Business login")
  }

  checkLoginStatus() {
    // Optional method - business apps typically don't auto-check status
    console.log("Skipping automatic login status check for business app")
    this.updateStatus("Click to connect Facebook Business account")
  }

  statusChangeCallback(response) {
    console.log("Facebook status change:", response)
    console.log("Full response object:", JSON.stringify(response, null, 2))
    
    if (response.status === 'connected') {
      // Person is logged into Facebook and your app
      console.log("User is connected to Facebook and our app")
      this.updateStatus("Already connected to Facebook!")
      this.handleConnectedUser(response.authResponse)
      
    } else if (response.status === 'not_authorized') {
      // Person is logged into Facebook but not your app
      console.log("User is logged into Facebook but not authorized for our app")
      this.updateStatus("Logged into Facebook, but app not authorized")
      this.showLoginButton()
      
    } else {
      // Person is not logged into Facebook, or unknown status
      console.log("User is not logged into Facebook, status:", response.status)
      this.updateStatus("Facebook status: " + response.status)
      this.showLoginButton()
    }
    
    // Show any error information
    if (response.error) {
      console.error("Facebook response error:", response.error)
      this.updateStatus("Facebook error: " + response.error.message)
    }
  }

  showLoginButton() {
    // Button is already visible, just update status
    if (this.hasButtonTarget) {
      this.buttonTarget.textContent = "Connect Facebook"
      this.buttonTarget.disabled = false
    }
  }

  handleConnectedUser(authResponse) {
    console.log("Handling connected user:", authResponse)
    this.updateStatus("Getting user info...")
    
    // Get user info and send to Rails
    FB.api('/me', { fields: 'name,email' }, (userInfo) => {
      console.log("Facebook user info:", userInfo)
      this.sendToRails(authResponse, userInfo)
    })
  }

  login() {
    console.log("Facebook Business login button clicked")
    this.updateStatus("Initiating Facebook Business login...")
    
    if (typeof FB === 'undefined') {
      this.updateStatus("ERROR: Facebook SDK not loaded")
      return
    }

    // Facebook Login for Business flow
    FB.login((response) => {
      console.log("Facebook Business login response:", response)
      console.log("Response status:", response.status)
      console.log("Full response:", JSON.stringify(response, null, 2))
      this.statusChangeCallback(response)
    }, {
      scope: 'email', // Business apps often need explicit scope
      return_scopes: true,
      auth_type: 'rerequest',
      // Business login specific options
      display: 'popup',
      response_type: 'code' // Use authorization code flow for business
    })
  }

  handleSuccessfulLogin(authResponse) {
    console.log("Handling successful Facebook login:", authResponse)
    this.updateStatus("Login successful, getting user info...")
    
    // Get user info
    FB.api('/me', { fields: 'name,email' }, (response) => {
      console.log("Facebook user info:", response)
      
      if (response.error) {
        console.error("Facebook API error:", response.error)
        this.updateStatus("Error getting user info: " + response.error.message)
        return
      }
      
      // Send to Rails backend
      this.sendToRails(authResponse, response)
    })
  }

  sendToRails(authResponse, userInfo) {
    const data = {
      access_token: authResponse.accessToken,
      user_id: authResponse.userID,
      expires_in: authResponse.expiresIn,
      user_info: userInfo
    }

    // Send to Rails callback endpoint
    fetch('/facebook/sdk_callback', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(data => {
      console.log("Rails response:", data)
      if (data.success) {
        this.updateStatus("Connected to Facebook successfully!")
        // Redirect to dashboard or refresh page
        window.location.href = '/dashboard'
      } else {
        this.updateStatus("Error: " + data.error)
      }
    })
    .catch(error => {
      console.error('Error:', error)
      this.updateStatus("Connection error: " + error.message)
    })
  }

  updateStatus(message) {
    console.log("Status:", message)
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }
}