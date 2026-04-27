module Admin
  class UsersController < BaseController
    def index
      authorize User, policy_class: Admin::UserPolicy
      @users = User.order(created_at: :desc).limit(100)
    end

    def show
      @user = User.find(params[:id])
      authorize @user, policy_class: Admin::UserPolicy
      @recent_sessions = @user.sessions.order(created_at: :desc).limit(20)
    end

    def update
      @user = User.find(params[:id])
      authorize @user, policy_class: Admin::UserPolicy
      @user.update!(role: user_params[:role])
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_users_path, notice: "권한이 변경되었습니다." }
      end
    end

    private

    def user_params
      params.require(:user).permit(:role)
    end
  end
end
