module Admin
  class GroupPolicy < ApplicationPolicy
    def index?   = user.admin?
    def show?    = user.admin?
    def create?  = user.admin?
    def new?     = create?
    def update?  = user.admin?
    def edit?    = update?
    def destroy? = user.admin?
  end
end
