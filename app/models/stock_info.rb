class StockInfo < ApplicationRecord
  belongs_to :user, optional: true

  validates :content,    presence: true
  validates :query,      presence: true
  validates :queried_at, presence: true

  scope :recent, -> { order(queried_at: :desc) }
  scope :search, ->(query, date_from, date_to) {
    conds, vals = [], []
    if query.present?
      conds << "(query LIKE ? OR content LIKE ?)"
      vals  << "%#{query}%" << "%#{query}%"
    end
    if date_from.present? && date_to.present?
      conds << "DATE(queried_at) BETWEEN ? AND ?"; vals << date_from << date_to
    elsif date_from.present?
      conds << "DATE(queried_at) >= ?"; vals << date_from
    elsif date_to.present?
      conds << "DATE(queried_at) <= ?"; vals << date_to
    end
    conds.empty? ? all : where(conds.join(" OR "), *vals)
  }
end
