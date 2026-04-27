require "test_helper"

module Admin
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    test "anonymous redirected" do
      get admin_sessions_path
      assert_redirected_to new_session_path
    end

    test "regular user blocked" do
      sign_in_as(users(:one))
      get admin_sessions_path
      assert_redirected_to root_path
    end

    test "admin index renders" do
      # Create a session row so the table has data, but the page must render either way.
      sign_in_as(users(:admin))
      get admin_sessions_path
      assert_response :success
    end
  end
end
