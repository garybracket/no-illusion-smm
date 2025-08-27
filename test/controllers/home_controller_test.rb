require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index without authentication" do
    get root_url
    assert_response :success
    assert_select "h1", text: /Publish to Facebook, Instagram, LinkedIn & TikTok/
  end

  test "should show sign up link when not authenticated" do
    get root_url
    assert_select "a[href=?]", "/auth/auth0", text: "Get Started Free →"
  end

  test "should include branding footer" do
    get root_url
    assert_select "footer" do
      assert_select "p", text: "Made with ❤️"
      assert_select "a[href='https://no-illusion.com']", text: "Designed, created, and property of No iLLusion Software"
    end
  end

  test "should have privacy-focused messaging" do
    get root_url
    assert_select "p", text: /Your posts never touch our database/
    assert_select "p", text: /process in memory and flush immediately/
  end
end