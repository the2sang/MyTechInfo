class PomodoroSetting < ApplicationRecord
  belongs_to :user

  validates :focus_minutes, numericality: { only_integer: true, in: 1..120 }
  validates :break_minutes, numericality: { only_integer: true, in: 1..60 }
end
