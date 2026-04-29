class ManpowerRecordPolicy < ApplicationPolicy
  def index?   = user.present?
  def create?  = user.present?
  def update?  = owner?
  def destroy? = owner?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user: user)
    end
  end

  private

  def owner? = record.user == user
end
