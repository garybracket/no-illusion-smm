// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// Explicitly import Facebook login controller
import FacebookLoginController from "controllers/facebook_login_controller"

// Auto-load all controllers
eagerLoadControllersFrom("controllers", application)

// Explicitly register Facebook login controller
application.register("facebook-login", FacebookLoginController)
