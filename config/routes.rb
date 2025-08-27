Rails.application.routes.draw do
  # Devise routes (skip omniauth callbacks - we handle Auth0 manually)
  devise_for :users, skip: [:omniauth_callbacks]
  
  # SECURITY: Auth0 callback routes (custom paths to match Auth0 config)
  get '/auth/callback', to: 'auth/omniauth#auth0'
  get '/auth/failure', to: 'auth/omniauth#failure'
  
  # Root route
  root "home#index"
  
  # Dashboard
  get "dashboard", to: "dashboard#index"
  
  # Profile management (since we disabled Devise registration)
  get "profile/edit", to: "profile#edit", as: :edit_user_profile
  patch "profile", to: "profile#update", as: :user_profile
  post "profile/setup_gary", to: "profile#setup_gary_profile", as: :setup_gary_profile
  post "profile/add_skill", to: "profile#add_skill", as: :add_skill
  delete "profile/remove_skill/:skill_name", to: "profile#remove_skill", as: :remove_skill
  
  # TODO: Re-implement Auth0 logout after Auth0 integration is restored
  # delete "logout", to: "auth/omniauth#logout", as: :destroy_user_session
  
  # AI Content Generation
  namespace :ai do
    post 'generate_post', to: 'ai#generate_post'
    post 'generate_suggestions', to: 'ai#generate_suggestions'
    post 'optimize_content', to: 'ai#optimize_content'
    post 'generate_and_post', to: 'ai#generate_and_post'
  end
  
  # Posts Management
  resources :posts do
    member do
      post :generate_content
    end
  end

  
  # Platform Connections
  resources :platform_connections, only: [:index] do
    collection do
      delete 'disconnect/:platform', to: 'platform_connections#disconnect', as: :disconnect
      post 'test/:platform', to: 'platform_connections#test_post', as: :test_post
    end
  end
  
  # LinkedIn OAuth (direct implementation)
  get '/linkedin/authorize', to: 'linkedin_oauth#authorize', as: :linkedin_authorize
  get '/users/auth/linkedin/callback', to: 'linkedin_oauth#callback', as: :linkedin_callback
  post '/linkedin/import_profile', to: 'linkedin_oauth#import_profile', as: :linkedin_import_profile
  post '/linkedin/export_profile', to: 'linkedin_oauth#export_profile', as: :linkedin_export_profile
  get '/linkedin/export_preview', to: 'linkedin_oauth#export_preview', as: :linkedin_export_preview
  
  # Resume Builder
  get '/resume', to: 'resume#show', as: :resume
  get '/resume/edit', to: 'resume#edit', as: :edit_resume
  patch '/resume', to: 'resume#update', as: :update_resume
  post '/resume/import', to: 'resume#import', as: :import_resume
  get '/resume/preview', to: 'resume#preview', as: :preview_resume
  get '/resume/download', to: 'resume#download', as: :download_resume
  post '/resume/sync_from_linkedin', to: 'resume#sync_from_linkedin', as: :sync_resume_from_linkedin
  
  # Legal pages
  get '/privacy', to: 'pages#privacy'
  get '/terms', to: 'pages#terms'
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
