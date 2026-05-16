class ParticipationPolicy < ApplicationPolicy
  def create? = true

  def destroy?
    return false if record.cancelled?
    user.present? && (user == record.user || user.admin?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.where(user: user)
    end
  end
end
