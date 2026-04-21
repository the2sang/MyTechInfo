class TechInfoReaction < ApplicationRecord
  belongs_to :user
  belongs_to :tech_info

  enum :kind, { good: 0, bad: 1 }

  validates :user_id, uniqueness: { scope: :tech_info_id }
  validates :kind, presence: true
end
