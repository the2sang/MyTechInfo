class GameSessionPolicy < ApplicationPolicy
  def index? = true
  def show?  = true

  def create?
    return false unless user.present?
    my_membership = user.club_memberships.find_by(club: record.club)
    (my_membership&.manager? && my_membership&.approved?) || user.admin?
  end

  def update? = create?
  def edit?   = update?
  def destroy? = user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.nil?
        scope.where(visibility: :public_visibility).open
      elsif user.admin?
        scope.all
      else
        approved_club_ids = user.club_memberships.approved.select(:club_id)
        scope.open.where(
          "visibility = ? OR club_id IN (?)",
          GameSession.visibilities[:public_visibility],
          approved_club_ids
        )
      end
    end
  end
end
