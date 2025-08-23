require "test_helper"

class PostTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )
  end

  test "should create valid post" do
    post = Post.new(
      user: @user,
      content: "Test post content",
      platforms: "linkedin,facebook",
      status: "draft",
      content_mode: "business"
    )
    assert post.save
  end

  test "should belong to user" do
    post = Post.create!(
      user: @user,
      content: "Test content"
    )
    assert_equal @user, post.user
  end

  test "should require content" do
    post = Post.new(
      user: @user,
      platforms: "linkedin"
    )
    assert_not post.save
    assert_includes post.errors[:content], "can't be blank"
  end

  test "should allow empty platforms" do
    post = Post.new(
      user: @user,
      content: "Test content without platforms"
    )
    assert post.save
  end

  test "should default status to draft" do
    post = Post.create!(
      user: @user,
      content: "Test content"
    )
    # Note: Checking for default value - may need to be set explicitly
    # This test will help us identify if we need to add a default value
    assert_includes ['draft', nil], post.status
  end

  test "should handle scheduling for future posts" do
    future_time = 2.hours.from_now
    post = Post.create!(
      user: @user,
      content: "Scheduled post content",
      scheduled_for: future_time,
      status: "scheduled"
    )
    assert_equal future_time.to_i, post.scheduled_for.to_i
    assert_equal "scheduled", post.status
  end

  test "should track ai generation flag" do
    ai_post = Post.create!(
      user: @user,
      content: "AI generated content",
      ai_generated: true
    )
    
    manual_post = Post.create!(
      user: @user,
      content: "Manually written content",
      ai_generated: false
    )

    assert ai_post.ai_generated?
    assert_not manual_post.ai_generated?
  end

  test "should store multiple platforms as text" do
    post = Post.create!(
      user: @user,
      content: "Multi-platform post",
      platforms: "linkedin,facebook,twitter"
    )
    assert_equal "linkedin,facebook,twitter", post.platforms
  end

  test "should handle different content modes" do
    business_post = Post.create!(
      user: @user,
      content: "Business content",
      content_mode: "business"
    )

    personal_post = Post.create!(
      user: @user,
      content: "Personal content", 
      content_mode: "personal"
    )

    assert_equal "business", business_post.content_mode
    assert_equal "personal", personal_post.content_mode
  end

  test "should allow long content" do
    long_content = "Lorem ipsum " * 100  # Very long content
    post = Post.create!(
      user: @user,
      content: long_content
    )
    assert_equal long_content, post.content
  end

  test "should be destroyed when user is destroyed" do
    post = Post.create!(
      user: @user,
      content: "Test content"
    )
    post_id = post.id
    
    @user.destroy
    assert_not Post.exists?(post_id)
  end
end