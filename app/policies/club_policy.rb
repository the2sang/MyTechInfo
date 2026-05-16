class ClubPolicy < ApplicationPolicy
  def index?  = true
  def show?   = record.approved? || (user.present? && user == record.owner)
  def new?    = true
  def create? = true
  def manage?
    return false unless user.present?
    membership = user.club_memberships.find_by(club: record)
    (membership&.manager? && membership&.approved?) || user.admin?
  end

  def update? = user.present? && (user == record.owner || user.admin?)
  def edit?   = update?
  def destroy? = user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.approved
    end
  end
end
