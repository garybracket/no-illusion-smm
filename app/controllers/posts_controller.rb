class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  
  def index
    @posts = current_user.posts.order(created_at: :desc)
  end
  
  def show
  end
  
  def new
    @post = current_user.posts.build
  end
  
  def create
    @post = current_user.posts.build(post_params)
    @post.content_mode = current_user.content_mode
    
    # Handle AI generation if requested
    if params[:generate_with_ai].present?
      ai_result = AiContentService.generate_post(
        user: current_user,
        prompt: @post.content,
        platform: selected_platforms.first
      )
      
      if ai_result[:success]
        @post.content = ai_result[:content]
        @post.ai_generated = true
      else
        flash.now[:alert] = "AI generation failed: #{ai_result[:error]}"
        render :new, status: :unprocessable_entity
        return
      end
    end
    
    # Set platforms and handle publishing
    @post.platforms = selected_platforms
    
    if @post.save
      # Handle immediate publishing
      if params[:publish_now] == '1' && @post.scheduled_for.blank?
        publish_to_platforms(@post)
      else
        @post.update(status: 'scheduled') if @post.scheduled_for.present?
      end
      
      redirect_to posts_path, notice: post_success_message
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @post.update(post_params)
      @post.platforms = selected_platforms
      @post.save
      
      # Handle republishing if requested
      if params[:publish_now] == '1'
        publish_to_platforms(@post)
      end
      
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @post.destroy
    redirect_to posts_path, notice: 'Post was successfully deleted.'
  end
  
  # AJAX endpoint for AI content generation
  def generate_content
    prompt = params[:prompt]
    platform = params[:platform]
    
    result = AiContentService.generate_post(
      user: current_user,
      prompt: prompt,
      platform: platform
    )
    
    if result[:success]
      render json: {
        success: true,
        content: result[:content],
        ai_generated: true
      }
    else
      render json: {
        success: false,
        error: result[:error],
        fallback_content: result[:fallback_content]
      }
    end
  end
  
  private
  
  def set_post
    @post = current_user.posts.find(params[:id])
  end
  
  def post_params
    params.require(:post).permit(:content, :scheduled_for, platforms: [])
  end
  
  def selected_platforms
    platforms = params[:post][:platforms]&.reject(&:blank?) || []
    
    # Handle "all" selection
    if platforms.include?('all')
      available_platforms
    else
      platforms
    end
  end
  
  def available_platforms
    platforms = []
    platforms << 'linkedin' if current_user.linkedin_connected?
    # Add other platforms as they become available
    platforms
  end
  
  def publish_to_platforms(post)
    published_count = 0
    failed_platforms = []
    
    post.platforms.each do |platform|
      case platform
      when 'linkedin'
        if current_user.linkedin_connected?
          result = LinkedinApiService.create_post(current_user.linkedin_connection, post.content)
          if result[:success]
            published_count += 1
          else
            failed_platforms << "LinkedIn: #{result[:error]}"
          end
        else
          failed_platforms << "LinkedIn: Not connected"
        end
      else
        failed_platforms << "#{platform.capitalize}: Not supported yet"
      end
    end
    
    if published_count > 0
      post.update(status: 'published')
    else
      post.update(status: 'failed')
    end
    
    # Set flash messages based on results
    if failed_platforms.any?
      flash[:alert] = "Publishing failed for: #{failed_platforms.join(', ')}"
    end
  end
  
  def post_success_message
    if @post.scheduled_for.present?
      "Post scheduled for #{@post.scheduled_for.strftime('%B %d, %Y at %I:%M %p')}"
    elsif @post.status == 'published'
      "Post published successfully to #{@post.platforms.join(', ').humanize}!"
    else
      "Post saved as draft"
    end
  end
end