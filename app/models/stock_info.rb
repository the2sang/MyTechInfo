class StockInfo < ApplicationRecord
  belongs_to :user, optional: true

  validates :content,    presence: true
  validates :query,      presence: true
  validates :queried_at, presence: true

  scope :recent, -> { order(queried_at: :desc) }
end
