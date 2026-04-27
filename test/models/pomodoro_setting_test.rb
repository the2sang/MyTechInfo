require "test_helper"

class PomodoroSettingTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @setting = PomodoroSetting.new(user: @user, focus_minutes: 25, break_minutes: 5)
  end

  test "valid with default values" do
    assert @setting.valid?
  end

  test "focus_minutes must be at least 1" do
    @setting.focus_minutes = 0
    assert_not @setting.valid?
    assert @setting.errors[:focus_minutes].any?
  end

  test "focus_minutes max is 120" do
    @setting.focus_minutes = 121
    assert_not @setting.valid?
  end

  test "break_minutes must be at least 1" do
    @setting.break_minutes = 0
    assert_not @setting.valid?
  end

  test "break_minutes max is 60" do
    @setting.break_minutes = 61
    assert_not @setting.valid?
  end

  test "belongs to user" do
    @setting.user = nil
    assert_not @setting.valid?
  end
end
