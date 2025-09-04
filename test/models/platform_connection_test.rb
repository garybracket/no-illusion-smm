require "test_helper"

class PlatformConnectionTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      auth0_id: "auth0|test123",
      content_mode: "business"
    )
  end

  test "should create valid platform connection" do
    connection = PlatformConnection.new(
      user: @user,
      platform_name: "linkedin",
      access_token: "test_token_123",
      is_active: true
    )
    assert connection.save
  end

  test "should require platform_name" do
    connection = PlatformConnection.new(
      user: @user,
      access_token: "test_token_123"
    )
    assert_not connection.save
    assert_includes connection.errors[:platform_name], "can't be blank"
  end

  test "should validate platform_name inclusion" do
    connection = PlatformConnection.new(
      user: @user,
      platform_name: "invalid_platform",
      access_token: "test_token_123"
    )
    assert_not connection.save
    assert_includes connection.errors[:platform_name], "is not included in the list"
  end

  test "should require access_token" do
    connection = PlatformConnection.new(
      user: @user,
      platform_name: "linkedin"
    )
    assert_not connection.save
    assert_includes connection.errors[:access_token], "can't be blank"
  end

  test "should enforce unique platform per user" do
    PlatformConnection.create!(
      user: @user,
      platform_name: "linkedin",
      access_token: "token1",
      is_active: true
    )

    duplicate_connection = PlatformConnection.new(
      user: @user,
      platform_name: "linkedin",
      access_token: "token2",
      is_active: true
    )

    assert_not duplicate_connection.save
    assert_includes duplicate_connection.errors[:platform_name], "has already been taken"
  end

  test "should allow same platform for different users" do
    user2 = User.create!(
      name: "Test User 2",
      email: "test2@example.com",
      auth0_id: "auth0|test456",
      content_mode: "business"
    )

    connection1 = PlatformConnection.create!(
      user: @user,
      platform_name: "linkedin",
      access_token: "token1",
      is_active: true
    )

    connection2 = PlatformConnection.new(
      user: user2,
      platform_name: "linkedin",
      access_token: "token2",
      is_active: true
    )

    assert connection2.save
  end

  test "should detect expired connections" do
    connection = PlatformConnection.create!(
      user: @user,
      platform_name: "linkedin",
      access_token: "test_token",
      expires_at: 1.hour.ago,
      is_active: true
    )

    assert connection.expired?
  end

  test "should detect non-expired connections" do
    connection = PlatformConnection.create!(
      user: @user,
      platform_name: "linkedin",
      access_token: "test_token",
      expires_at: 1.hour.from_now,
      is_active: true
    )

    assert_not connection.expired?
  end

  test "should validate connection properly" do
    valid_connection = PlatformConnection.create!(
      user: @user,
      platform_name: "linkedin",
      access_token: "test_token",
      expires_at: 1.hour.from_now,
      is_active: true
    )

    assert valid_connection.valid_connection?
  end

  test "should invalidate expired connection" do
    invalid_connection = PlatformConnection.create!(
      user: @user,
      platform_name: "linkedin",
      access_token: "test_token",
      expires_at: 1.hour.ago,
      is_active: true
    )

    assert_not invalid_connection.valid_connection?
  end

  test "should invalidate inactive connection" do
    inactive_connection = PlatformConnection.create!(
      user: @user,
      platform_name: "linkedin",
      access_token: "test_token",
      expires_at: 1.hour.from_now,
      is_active: false
    )

    assert_not inactive_connection.valid_connection?
  end

  test "should identify linkedin connections" do
    linkedin_connection = PlatformConnection.create!(
      user: @user,
      platform_name: "linkedin",
      access_token: "test_token",
      is_active: true
    )

    facebook_connection = PlatformConnection.create!(
      user: @user,
      platform_name: "facebook",
      access_token: "test_token",
      is_active: true
    )

    assert linkedin_connection.linkedin?
    assert_not facebook_connection.linkedin?
  end

  test "should scope active connections" do
    active_connection = PlatformConnection.create!(
      user: @user,
      platform_name: "linkedin",
      access_token: "test_token",
      is_active: true
    )

    inactive_connection = PlatformConnection.create!(
      user: @user,
      platform_name: "facebook",
      access_token: "test_token",
      is_active: false
    )

    active_connections = PlatformConnection.active
    assert_includes active_connections, active_connection
    assert_not_includes active_connections, inactive_connection
  end

  test "should scope by platform" do
    linkedin_connection = PlatformConnection.create!(
      user: @user,
      platform_name: "linkedin",
      access_token: "test_token",
      is_active: true
    )

    facebook_connection = PlatformConnection.create!(
      user: @user,
      platform_name: "facebook",
      access_token: "test_token",
      is_active: true
    )

    linkedin_connections = PlatformConnection.for_platform("linkedin")
    assert_includes linkedin_connections, linkedin_connection
    assert_not_includes linkedin_connections, facebook_connection
  end
end
