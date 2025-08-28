// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import PostFormController from "./post_form_controller"

// Explicitly register the PostFormController
application.register("post-form", PostFormController)

// Auto-load other controllers
eagerLoadControllersFrom("controllers", application)
