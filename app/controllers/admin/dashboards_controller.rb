module Admin
  class DashboardsController < BaseController
    def index
      authorize [ :admin, :dashboard ], :index?

      @user_count          = User.count
      @admin_count         = User.admin.count
      @new_users_this_week = User.where(created_at: 1.week.ago..).count
      @sessions_today      = Session.where(created_at: 1.day.ago..).count
      @recent_users        = User.order(created_at: :desc).limit(5)
      @recent_sessions     = Session.includes(:user).order(created_at: :desc).limit(10)
    end
  end
end
