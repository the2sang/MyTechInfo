require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "sport_level enum values are defined" do
    assert User.sport_levels.keys == %w[beginner intermediate advanced pro]
  end

  test "age_group enum values are defined" do
    assert User.age_groups.keys == %w[twenties thirties forties fifties sixties_plus]
  end

  test "gender enum values are defined" do
    assert User.genders.keys == %w[unspecified male female other]
  end
end
