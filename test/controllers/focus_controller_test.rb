require "test_helper"

class FocusControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "show renders successfully for new user without setting" do
    get focus_url
    assert_response :success
  end

  test "show loads existing setting" do
    @user.create_pomodoro_setting!(focus_minutes: 30, break_minutes: 10, long_break_minutes: 20, rounds: 4)
    get focus_url
    assert_response :success
  end

  test "unauthenticated user is redirected" do
    delete session_url
    get focus_url
    assert_redirected_to new_session_url
  end
end

class Focus::SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "show renders settings page" do
    get focus_settings_url
    assert_response :success
  end

  test "update saves valid settings" do
    patch focus_settings_url, params: {
      pomodoro_setting: { focus_minutes: 45, break_minutes: 10, long_break_minutes: 25, rounds: 3, auto_start: false }
    }
    assert_redirected_to focus_url
    assert_equal 45, @user.reload.pomodoro_setting.focus_minutes
  end

  test "update rejects invalid settings" do
    patch focus_settings_url, params: {
      pomodoro_setting: { focus_minutes: 0, break_minutes: 5, long_break_minutes: 20, rounds: 4 }
    }
    assert_response :unprocessable_entity
  end

  test "unauthenticated user is redirected" do
    delete session_url
    get focus_settings_url
    assert_redirected_to new_session_url
  end
end
