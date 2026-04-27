module Focus
  class SettingsController < ApplicationController
    before_action :require_authentication

    def show
      @setting = current_user.pomodoro_setting ||
                 current_user.build_pomodoro_setting
      authorize @setting, policy_class: PomodoroSettingPolicy
    end

    def update
      @setting = current_user.pomodoro_setting ||
                 current_user.build_pomodoro_setting
      authorize @setting, policy_class: PomodoroSettingPolicy
      if @setting.update(setting_params)
        redirect_to focus_path, notice: "설정이 저장되었습니다."
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def setting_params
      params.require(:pomodoro_setting).permit(
        :focus_minutes, :break_minutes, :long_break_minutes, :rounds, :auto_start
      )
    end
  end
end
