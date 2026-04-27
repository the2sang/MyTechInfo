require "test_helper"

class AdminHeaderIconTest < ActionDispatch::IntegrationTest
  test "anonymous does not see admin icon" do
    get root_path
    assert_response :success
    assert_select "a.nav__icon-btn--admin", false
  end

  test "regular user does not see admin icon" do
    sign_in_as(users(:one))
    get root_path
    assert_response :success
    assert_select "a.nav__icon-btn--admin", false
  end

  test "admin sees admin icon linking to admin dashboard" do
    sign_in_as(users(:admin))
    get root_path
    assert_response :success
    assert_select "a.nav__icon-btn--admin[href=?]", admin_root_path
  end
end
