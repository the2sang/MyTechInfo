class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :user

  ROLES = { member: 0, owner: 1 }.freeze
  enum :role, ROLES

  validates :user_id, uniqueness: { scope: :group_id }
end
