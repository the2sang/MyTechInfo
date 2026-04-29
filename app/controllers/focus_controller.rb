class FocusController < ApplicationController
  allow_unauthenticated_access

  def show
    @setting = authenticated? ? (current_user.pomodoro_setting || current_user.build_pomodoro_setting) : PomodoroSetting.new
  end
end
