class ManpowerRecord < ApplicationRecord
  belongs_to :user

  validates :request_date, presence: true
  validates :start_date,   presence: true
  validates :end_date,     presence: true
  validates :work_minutes, presence: true,
                           numericality: { only_integer: true, greater_than: 0 }
  validates :description,  presence: true

  validate :end_date_not_before_start_date

  scope :for_month, ->(year, month) {
    start = Date.new(year.to_i, month.to_i, 1)
    where(request_date: start..start.end_of_month)
  }
  scope :by_request_date, -> { order(:request_date, :created_at) }

  private

  def end_date_not_before_start_date
    return unless start_date && end_date
    errors.add(:end_date, "는 처리시작일 이후여야 합니다") if end_date < start_date
  end
end
