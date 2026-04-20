class Comment < ApplicationRecord
  belongs_to :tech_info
  belongs_to :user

  validates :body, presence: true, length: { maximum: 1000 }

  scope :oldest, -> { order(created_at: :asc) }
end
