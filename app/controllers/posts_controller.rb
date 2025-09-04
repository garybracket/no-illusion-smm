class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]

  def index
    @posts = current_user.posts.order(created_at: :desc)
  end

  def show
  end

  def new
    @post = current_user.posts.build
    @preferred_platform = params[:platform] if params[:platform].present?
  end

  def create
    # PRIVACY FIRST: Never save content to database
    content = post_params[:content] # Get content but don't persist it

    # Validate content exists
    if content.blank?
      flash.now[:alert] = "Content cannot be empty"
      @post = current_user.posts.build
      render :new, status: :unprocessable_entity
      return
    end

    # Handle AI generation if requested
    if params[:generate_with_ai].present?
      ai_result = AiContentService.generate_post(
        user: current_user,
        prompt: content,
        platform: selected_platforms.first
      )

      if ai_result[:success]
        content = ai_result[:content] # Use AI generated content but don't save
        ai_generated = true
      else
        flash.now[:alert] = "AI generation failed: #{ai_result[:error]}"
        @post = current_user.posts.build
        render :new, status: :unprocessable_entity
        return
      end
    end

    # Create post with metadata only (NO content storage)
    @post = current_user.posts.build
    @post.content = content # This sets content_length and content_hash only
    @post.content_mode = post_params[:content_mode] || current_user.content_mode
    @post.platforms = selected_platforms
    @post.ai_generated = ai_generated || false
    @post.scheduled_for = post_params[:scheduled_for]

    if @post.save
      # Handle immediate publishing
      if params[:publish_now] == "1" && @post.scheduled_for.blank?
        publish_result = publish_to_platforms(@post, content) # Pass content to publish method
        if publish_result[:success]
          redirect_to posts_path, notice: "Post published successfully! Content was processed and discarded for privacy."
        else
          redirect_to posts_path, alert: "Publishing failed: #{publish_result[:error]}"
        end
      else
        @post.update(status: "scheduled") if @post.scheduled_for.present?
        redirect_to posts_path, notice: "Post metadata saved. Content will be generated and published when scheduled (content not stored for privacy)."
      end
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
      if params[:publish_now] == "1"
        publish_to_platforms(@post)
      end

      redirect_to @post, notice: "Post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "Post was successfully deleted."
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
    # PRIVACY: Content is permitted for processing but never persisted
    params.require(:post).permit(:content, :content_mode, :scheduled_for, platforms: [])
  end

  def selected_platforms
    platforms = params[:post][:platforms]&.reject(&:blank?) || []

    # Handle "all" selection
    if platforms.include?("all")
      available_platforms
    else
      platforms
    end
  end

  def available_platforms
    platforms = []
    platforms << "linkedin" if current_user.linkedin_connected?
    platforms << "facebook" if current_user.facebook_connected?
    # Add other platforms as they become available
    platforms
  end

  def publish_to_platforms(post, content)
    published_count = 0
    failed_platforms = []
    platform_post_ids = {}

    post.platforms.each do |platform|
      case platform
      when "linkedin"
        if current_user.linkedin_connected?
          result = LinkedinApiService.create_post(current_user.linkedin_connection, content)
          if result[:success]
            published_count += 1
            platform_post_ids["linkedin"] = result[:post_id] if result[:post_id]
          else
            failed_platforms << "LinkedIn: #{result[:error]}"
          end
        else
          failed_platforms << "LinkedIn: Not connected"
        end
      when "facebook"
        if current_user.facebook_connected?
          # Post to all connected Facebook pages
          facebook_service = FacebookApiService.new(current_user)
          current_user.facebook_connections.each do |connection|
            result = facebook_service.post_to_page(content, connection.id)
            if result[:success]
              published_count += 1
              platform_post_ids["facebook_#{connection.platform_user_id}"] = result[:post_id]
            else
              failed_platforms << "Facebook (#{connection.facebook_page_name}): #{result[:error]}"
            end
          end
        else
          failed_platforms << "Facebook: Not connected"
        end
      else
        failed_platforms << "#{platform.capitalize}: Not supported yet"
      end
    end

    # Update post status and save platform IDs (but never content)
    if published_count > 0
      post.update(status: "published", platform_post_ids: platform_post_ids)
    else
      post.update(status: "failed")
    end

    # Return result instead of setting flash (let caller handle messaging)
    {
      success: published_count > 0,
      published_count: published_count,
      failed_platforms: failed_platforms,
      error: failed_platforms.any? ? "Failed: #{failed_platforms.join(', ')}" : nil
    }
  end

  def post_success_message
    if @post.scheduled_for.present?
      "Post scheduled for #{@post.scheduled_for.strftime('%B %d, %Y at %I:%M %p')}"
    elsif @post.status == "published"
      "Post published successfully to #{@post.platforms.join(', ').humanize}!"
    else
      "Post saved as draft"
    end
  end
end
