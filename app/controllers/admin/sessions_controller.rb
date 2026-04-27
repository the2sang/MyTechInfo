module Admin
  class SessionsController < BaseController
    def index
      authorize Session, policy_class: Admin::SessionPolicy
      @sessions = Session.includes(:user).order(created_at: :desc).limit(200)
    end
  end
end
