class WorkJournal < ApplicationRecord
  belongs_to :user

  CATEGORIES = { task: 0, meeting: 1, planning: 2, issue: 3, etc: 4 }.freeze
  STATUSES   = { in_progress: 0, completed: 1, on_hold: 2 }.freeze
  FORMATS    = %w[markdown html].freeze

  enum :category, CATEGORIES
  enum :status,   STATUSES

  validates :title,          presence: true, length: { maximum: 200 }
  validates :content,        presence: true
  validates :content_format, presence: true, inclusion: { in: FORMATS }
  validates :work_date,      presence: true
  validates :progress,       numericality: { only_integer: true,
                                              greater_than_or_equal_to: 0,
                                              less_than_or_equal_to: 100 }

  scope :for_month, ->(year, month) {
    start_date = Date.new(year.to_i, month.to_i, 1)
    where(work_date: start_date..start_date.end_of_month)
  }

  scope :recent, -> { order(work_date: :desc, created_at: :desc) }
end
