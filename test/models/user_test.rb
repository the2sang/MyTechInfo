require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "sport_level enum values are defined" do
    assert_equal %w[beginner intermediate advanced pro], User.sport_levels.keys
  end

  test "age_group enum values are defined" do
    assert_equal %w[twenties thirties forties fifties sixties_plus], User.age_groups.keys
  end

  test "gender enum values are defined" do
    assert_equal %w[unspecified male female other], User.genders.keys
  end
end
