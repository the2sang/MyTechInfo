class ParticipationPolicy < ApplicationPolicy
  def create?
    user.present? && user.profile_complete?
  end

  def destroy?
    return false if record.cancelled?
    return false unless user.present?
    return true if club_manager? || user.admin?
    user == record.user && !record.game_session.session_ended?
  end

  private

  def club_manager?
    membership = user.club_memberships.find_by(club: record.game_session.club)
    membership&.manager? && membership&.approved?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.where(user: user)
    end
  end
end
