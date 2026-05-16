class ClubPolicy < ApplicationPolicy
  def index?  = true
  def show?   = record.approved?
  def new?    = user.present?
  def create? = user.present?
  def update? = user.present? && (user == record.owner || user.admin?)
  def edit?   = update?
  def destroy? = user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.approved
    end
  end
end
