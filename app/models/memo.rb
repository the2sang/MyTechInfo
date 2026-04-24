class Memo < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 100 }
  validates :content, length: { maximum: 2000 }

  ACCENT_COLORS = %w[#7b42bc #f59e0b #14c6cb #e05252 #22c55e #3b82f6 #f97316 #ec4899].freeze

  def accent_color
    ACCENT_COLORS[id % ACCENT_COLORS.length]
  end

  scope :recent, -> { order(created_at: :desc) }
  scope :search, ->(query, date_from, date_to) {
    conds, vals = [], []
    if query.present?
      conds << "(title LIKE ? OR content LIKE ?)"
      vals  << "%#{query}%" << "%#{query}%"
    end
    if date_from.present? || date_to.present?
      if date_from.present? && date_to.present?
        conds << "DATE(created_at) BETWEEN ? AND ?"
        vals  << date_from << date_to
      elsif date_from.present?
        conds << "DATE(created_at) >= ?"
        vals  << date_from
      else
        conds << "DATE(created_at) <= ?"
        vals  << date_to
      end
    end
    conds.empty? ? all : where(conds.join(" OR "), *vals)
  }
end
