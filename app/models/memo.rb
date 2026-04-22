class Memo < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 100 }
  validates :content, length: { maximum: 2000 }

  ACCENT_COLORS = %w[#7b42bc #f59e0b #14c6cb #e05252 #22c55e #3b82f6 #f97316 #ec4899].freeze

  def accent_color
    ACCENT_COLORS[id % ACCENT_COLORS.length]
  end

  scope :recent, -> { order(created_at: :desc) }
end
