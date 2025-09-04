require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @valid_auth = {
      "uid" => "auth0|test123",
      "info" => {
        "email" => "test@example.com",
        "name" => "Test User"
      }
    }
  end

  test "should create valid user" do
    user = User.new(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )
    assert user.save
  end

  test "should require name" do
    user = User.new(
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )
    assert_not user.save
    assert_includes user.errors[:name], "can't be blank"
  end

  test "should require email" do
    user = User.new(
      name: "Test User",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )
    assert_not user.save
    assert_includes user.errors[:email], "can't be blank"
  end

  test "should validate email format" do
    user = User.new(
      name: "Test User",
      email: "invalid-email",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )
    assert_not user.save
    assert_includes user.errors[:email], "is invalid"
  end

  test "should require unique email" do
    User.create!(
      name: "First User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )

    duplicate_user = User.new(
      name: "Second User",
      email: "test@example.com",
      auth0_id: "auth0|test456",
      content_mode: "business"
    )

    assert_not duplicate_user.save
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "should require unique auth0_id when present" do
    User.create!(
      name: "First User",
      email: "test1@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )

    duplicate_user = User.new(
      name: "Second User",
      email: "test2@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )

    assert_not duplicate_user.save
    assert_includes duplicate_user.errors[:auth0_id], "has already been taken"
  end

  test "should allow multiple users with nil auth0_id" do
    user1 = User.create!(
      name: "User 1",
      email: "test1@example.com",
      content_mode: "business"
    )

    user2 = User.create!(
      name: "User 2",
      email: "test2@example.com",
      content_mode: "business"
    )

    assert user1.persisted?
    assert user2.persisted?
    assert_nil user1.auth0_id
    assert_nil user2.auth0_id
  end

  test "should have default content_mode of business" do
    user = User.new(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123"
    )
    assert user.save
    assert_equal "business", user.content_mode
  end

  test "should validate content_mode enum" do
    user = User.new(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )
    assert user.save
    assert_equal "business", user.content_mode

    # Test that invalid enum values are rejected
    assert_raises(ArgumentError) do
      user.content_mode = "invalid_mode"
    end
  end

  test "should have many posts" do
    user = User.create!(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )

    post1 = user.posts.create!(content: "First post")
    post2 = user.posts.create!(content: "Second post")

    assert_includes user.posts, post1
    assert_includes user.posts, post2
    assert_equal 2, user.posts.count
  end

  test "should destroy posts when user is destroyed" do
    user = User.create!(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )

    post = user.posts.create!(content: "Test post")
    post_id = post.id

    user.destroy
    assert_not Post.exists?(post_id)
  end

  test "should have many platform_connections" do
    user = User.create!(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )

    connection = user.platform_connections.create!(
      platform_name: "linkedin",
      access_token: "test_token",
      is_active: true
    )

    assert_includes user.platform_connections, connection
  end

  test "linkedin_connection should return active linkedin connection" do
    user = User.create!(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )

    # Create LinkedIn connection
    linkedin_conn = user.platform_connections.create!(
      platform_name: "linkedin",
      access_token: "linkedin_token",
      is_active: true
    )

    # Create Facebook connection for contrast
    user.platform_connections.create!(
      platform_name: "facebook",
      access_token: "facebook_token",
      is_active: true
    )

    assert_equal linkedin_conn, user.linkedin_connection
  end

  test "linkedin_connection should return nil when no active linkedin connection" do
    user = User.create!(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )

    # Create inactive LinkedIn connection
    user.platform_connections.create!(
      platform_name: "linkedin",
      access_token: "linkedin_token",
      is_active: false
    )

    assert_nil user.linkedin_connection
  end

  test "linkedin_connected? should return true with valid connection" do
    user = User.create!(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )

    user.platform_connections.create!(
      platform_name: "linkedin",
      access_token: "linkedin_token",
      expires_at: 1.hour.from_now,
      is_active: true
    )

    assert user.linkedin_connected?
  end

  test "linkedin_connected? should return false with no connection" do
    user = User.create!(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )

    assert_not user.linkedin_connected?
  end

  test "linkedin_connected? should return false with expired connection" do
    user = User.create!(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )

    user.platform_connections.create!(
      platform_name: "linkedin",
      access_token: "linkedin_token",
      expires_at: 1.hour.ago,
      is_active: true
    )

    assert_not user.linkedin_connected?
  end

  test "should set default ai_preferences on creation" do
    user = User.create!(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )

    assert_not_nil user.ai_preferences
    assert user.ai_preferences["generation"]
    assert user.ai_preferences["suggestions"]
    assert user.ai_preferences["optimization"]
    assert_equal 3, user.ai_preferences["providers"].keys.count
    assert user.ai_preferences["providers"]["openai"]["enabled"]
  end

  test "should not override existing ai_preferences" do
    custom_preferences = {
      "generation" => false,
      "custom_setting" => true
    }

    user = User.new(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business",
      ai_preferences: custom_preferences
    )

    user.save!
    assert_equal custom_preferences, user.ai_preferences
  end

  # Auth0 Integration Tests
  test "from_omniauth should find existing user by auth0_id" do
    existing_user = User.create!(
      name: "Existing User",
      email: "existing@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )

    user = User.from_omniauth(@valid_auth)
    assert_equal existing_user.id, user.id
  end

  test "from_omniauth should find existing user by email and update auth0_id" do
    existing_user = User.create!(
      name: "Existing User",
      email: "test@example.com",
      content_mode: "business"
    )

    user = User.from_omniauth(@valid_auth)
    assert_equal existing_user.id, user.id
    assert_equal "auth0|test123", user.auth0_id
  end

  test "from_omniauth should create new user when not found" do
    initial_count = User.count
    user = User.from_omniauth(@valid_auth)

    assert_equal initial_count + 1, User.count
    assert_equal "test@example.com", user.email
    assert_equal "Test User", user.name
    assert_equal "auth0|test123", user.auth0_id
    assert_equal "business", user.content_mode
  end

  test "from_omniauth should handle missing name gracefully" do
    auth_without_name = {
      "uid" => "auth0|test123",
      "info" => {
        "email" => "test@example.com"
      }
    }

    user = User.from_omniauth(auth_without_name)
    assert_equal "test", user.name  # Should use email prefix
  end

  test "from_omniauth should return nil for invalid auth" do
    invalid_auth = {
      "uid" => nil,
      "info" => {
        "email" => "test@example.com"
      }
    }

    user = User.from_omniauth(invalid_auth)
    assert_nil user
  end

  test "from_omniauth should return nil for missing email" do
    invalid_auth = {
      "uid" => "auth0|test123",
      "info" => {
        "name" => "Test User"
      }
    }

    user = User.from_omniauth(invalid_auth)
    assert_nil user
  end

  test "from_omniauth should update auth0_id for existing email" do
    # Create a user with the same email but different auth0_id
    existing = User.create!(
      name: "Existing User",
      email: "test@example.com",
      auth0_id: "auth0|different123",
      content_mode: "business"
    )

    # This should update the auth0_id to the new one from Auth0
    user = User.from_omniauth(@valid_auth)
    assert_equal existing.id, user.id
    assert_equal "auth0|test123", user.reload.auth0_id
  end
end
