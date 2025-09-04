class Ai::AiController < ApplicationController
  before_action :authenticate_user!

  def generate_post
    result = AiContentService.generate_post(
      user: current_user,
      prompt: params[:prompt],
      platform: params[:platform],
      content_mode: params[:content_mode]
    )

    if result[:success]
      render json: {
        success: true,
        content: result[:content],
        ai_generated: result[:ai_generated],
        provider: result[:provider],
        model: result[:model]
      }
    else
      render json: {
        success: false,
        error: result[:error],
        fallback_content: result[:fallback_content]
      }, status: :unprocessable_entity
    end
  end

  def generate_suggestions
    result = AiContentService.generate_suggestions(
      user: current_user,
      context: params[:context]
    )

    render json: result
  end

  def optimize_content
    result = AiContentService.optimize_content(
      content: params[:content],
      platform: params[:platform]
    )

    render json: {
      success: true,
      content: result
    }
  end

  def generate_and_post
    platform = params[:platform]
    prompt = params[:prompt]

    # Generate content with AI
    ai_result = AiContentService.generate_post(
      user: current_user,
      prompt: prompt,
      platform: platform
    )

    unless ai_result[:success]
      redirect_to dashboard_path, alert: "AI generation failed: #{ai_result[:error]}"
      return
    end

    # Post to platform
    case platform
    when "linkedin"
      connection = current_user.linkedin_connection

      unless connection&.valid_connection?
        redirect_to dashboard_path, alert: "LinkedIn not connected or connection expired"
        return
      end

      post_result = LinkedinApiService.create_post(connection, ai_result[:content])

      if post_result[:success]
        # Save the post to database
        post = current_user.posts.create!(
          content: ai_result[:content],
          platforms: [ platform ],
          status: "published",
          content_mode: current_user.content_mode,
          ai_generated: true
        )

        redirect_to dashboard_path,
                    notice: "🎉 Success! AI generated and posted to LinkedIn: \"#{ai_result[:content][0..50]}...\""
      else
        redirect_to dashboard_path, alert: "LinkedIn posting failed: #{post_result[:error]}"
      end
    else
      redirect_to dashboard_path, alert: "Platform #{platform} not supported yet"
    end
  end
end
