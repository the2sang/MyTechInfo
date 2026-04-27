require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    test "anonymous redirected" do
      get admin_users_path
      assert_redirected_to new_session_path
    end

    test "regular user blocked" do
      sign_in_as(users(:one))
      get admin_users_path
      assert_redirected_to root_path
    end

    test "admin index lists users" do
      sign_in_as(users(:admin))
      get admin_users_path
      assert_response :success
      assert_select "table.admin-table"
    end

    test "admin show renders user" do
      sign_in_as(users(:admin))
      get admin_user_path(users(:one))
      assert_response :success
      assert_select "dl.admin-dl"
    end
  end
end
