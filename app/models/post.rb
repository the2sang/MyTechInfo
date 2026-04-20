class Post < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { minimum: 1, maximum: 280 }

  scope :recent, -> { order(created_at: :desc) }
end
