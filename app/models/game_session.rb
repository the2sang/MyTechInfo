class GameSession < ApplicationRecord
  belongs_to :club
  has_many :participations, dependent: :destroy
  belongs_to :template, class_name: "GameSession", optional: true
  has_many :instances, class_name: "GameSession", foreign_key: :template_id, dependent: :nullify

  enum :visibility,   { public_visibility: 0, members_only: 1 }, default: :public_visibility
  enum :status,       { open: 0, closed: 1, cancelled: 2 }, default: :open
  enum :repeat_type,  { no_repeat: 0, daily: 1, weekly: 2, specific_days: 3 }, default: :no_repeat

  DAYS_KO = %w[일 월 화 수 목 금 토].freeze

  scope :templates, -> { where(template_id: nil).where.not(repeat_type: :no_repeat) }

  validates :title, :venue_name, :scheduled_date, :start_time, :end_time, presence: true
  validates :fee,              numericality: { greater_than_or_equal_to: 0 }
  validates :court_count,      numericality: { greater_than: 0 }, allow_nil: true
  validates :max_participants,  numericality: { greater_than: 0 }, allow_nil: true

  def repeating? = !no_repeat?

  def repeat_days_array
    repeat_days.present? ? repeat_days.split(",").map(&:to_i) : []
  end

  def repeat_days_label
    case repeat_type
    when "daily"    then "매일"
    when "weekly"   then "매주 #{DAYS_KO[scheduled_date.wday]}요일"
    when "specific_days" then repeat_days_array.map { DAYS_KO[_1] }.join("/") + "요일"
    end
  end

  def should_run_today?(date = Date.today)
    return false if repeat_ends_on.present? && date > repeat_ends_on
    case repeat_type
    when "daily"         then true
    when "weekly"        then date.wday == scheduled_date.wday
    when "specific_days" then repeat_days_array.include?(date.wday)
    else false
    end
  end

  def full?
    return false if max_participants.nil?
    confirmed_count >= max_participants
  end

  def confirmed_count
    participations.confirmed.count
  end

  def session_ended?
    scheduled_date < Date.today ||
      (scheduled_date == Date.today && end_time < Time.current)
  end
end
