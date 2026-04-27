class FocusController < ApplicationController
  before_action :require_authentication

  def show
    @setting = current_user.pomodoro_setting ||
               current_user.build_pomodoro_setting
    authorize @setting, policy_class: PomodoroSettingPolicy
  end
end
