class WorkPlan < ApplicationRecord
  belongs_to :user

  validates :department_name, presence: true, length: { maximum: 100 }
  validates :work_name,       presence: true, length: { maximum: 200 }
  validates :work_at,         presence: true
  validates :work_content,    presence: true
  validates :doc_date,        presence: true

  scope :for_month, ->(year, month) {
    start_date = Date.new(year.to_i, month.to_i, 1)
    where(work_at: start_date.beginning_of_day..start_date.end_of_month.end_of_day)
  }

  scope :recent, -> { order(work_at: :asc) }
end
