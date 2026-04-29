class WorkJournalPolicy < ApplicationPolicy
  def index?   = user.present?
  def show?    = owner? || group_member?
  def create?  = user.present?
  def new?     = create?
  def update?  = owner?
  def edit?    = update?
  def destroy? = owner?

  class Scope < ApplicationPolicy::Scope
    def resolve
      visible_user_ids = GroupMembership.where(
        group_id: user.group_memberships.select(:group_id)
      ).select(:user_id)
      scope.where(user_id: visible_user_ids)
    end
  end

  private

  def owner?
    record.user == user
  end

  def group_member?
    shared_group_ids = user.group_memberships.select(:group_id)
    GroupMembership.exists?(group_id: shared_group_ids, user_id: record.user_id)
  end
end
