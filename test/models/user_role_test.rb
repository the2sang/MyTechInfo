require "test_helper"

class UserRoleTest < ActiveSupport::TestCase
  test "default role is user" do
    u = User.new(email_address: "x@example.com", nickname: "rolex")
    assert_equal "user", u.role
    assert u.user?
    assert_not u.admin?
  end

  test "admin? predicate" do
    admin = users(:admin)
    assert admin.admin?
    assert_not admin.user?
  end

  test "scopes" do
    assert_includes User.admin.to_a,        users(:admin)
    assert_not_includes User.admin.to_a,    users(:one)
    assert_includes User.user.to_a,         users(:one)
    assert_not_includes User.user.to_a,     users(:admin)
  end

  test "promote via update" do
    u = users(:one)
    u.update!(role: :admin)
    assert u.reload.admin?
  end
end
