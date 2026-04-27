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
  end
end
