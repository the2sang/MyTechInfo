require "test_helper"

class PomodoroSettingTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @setting = PomodoroSetting.new(
      user: @user, focus_minutes: 25, break_minutes: 5,
      long_break_minutes: 20, rounds: 4, auto_start: false
    )
  end

  test "valid with default values" do
    assert @setting.valid?
  end

  test "focus_minutes min is 5" do
    @setting.focus_minutes = 4
    assert_not @setting.valid?
    assert @setting.errors[:focus_minutes].any?
  end

  test "focus_minutes max is 60" do
    @setting.focus_minutes = 61
    assert_not @setting.valid?
  end

  test "break_minutes min is 1" do
    @setting.break_minutes = 0
    assert_not @setting.valid?
  end

  test "break_minutes max is 30" do
    @setting.break_minutes = 31
    assert_not @setting.valid?
  end

  test "long_break_minutes max is 45" do
    @setting.long_break_minutes = 46
    assert_not @setting.valid?
  end

  test "rounds min is 2" do
    @setting.rounds = 1
    assert_not @setting.valid?
  end

  test "rounds max is 15" do
    @setting.rounds = 16
    assert_not @setting.valid?
  end

  test "belongs to user" do
    @setting.user = nil
    assert_not @setting.valid?
  end
end
