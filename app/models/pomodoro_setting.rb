class PomodoroSetting < ApplicationRecord
  belongs_to :user

  validates :focus_minutes,      numericality: { only_integer: true, in: 5..60 }
  validates :break_minutes,      numericality: { only_integer: true, in: 1..30 }
  validates :long_break_minutes, numericality: { only_integer: true, in: 1..45 }
  validates :rounds,             numericality: { only_integer: true, in: 2..15 }
end
