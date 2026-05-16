class ClubMembershipPolicy < ApplicationPolicy
  def create? = user.present?

  def update?
    return false unless user.present?
    my_membership = user.club_memberships.find_by(club: record.club)
    (my_membership&.manager? && my_membership&.approved?) || user.admin?
  end

  def destroy?
    user.present? && (user == record.user || update?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.all
  end
end
