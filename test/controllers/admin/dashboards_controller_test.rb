require "test_helper"

module Admin
  class DashboardsControllerTest < ActionDispatch::IntegrationTest
    test "anonymous redirected to sign-in" do
      get admin_root_path
      assert_redirected_to new_session_path
    end

    test "regular user blocked" do
      sign_in_as(users(:one))
      get admin_root_path
      assert_redirected_to root_path
      assert_match "관리자 권한", flash[:alert].to_s
    end

    test "admin sees dashboard" do
      sign_in_as(users(:admin))
      get admin_root_path
      assert_response :success
      assert_select "h1", text: /Admin/
    end
  end
end
