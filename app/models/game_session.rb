class GameSession < ApplicationRecord
  belongs_to :club
  has_many :participations, dependent: :destroy

  enum :visibility, { public_visibility: 0, members_only: 1 }, default: :public_visibility
  enum :status,     { open: 0, closed: 1, cancelled: 2 }, default: :open

  validates :title, :venue_name, :scheduled_date, :start_time, :end_time, presence: true
  validates :fee,              numericality: { greater_than_or_equal_to: 0 }
  validates :court_count,      numericality: { greater_than: 0 }, allow_nil: true
  validates :max_participants,  numericality: { greater_than: 0 }, allow_nil: true

  def full?
    return false if max_participants.nil?
    confirmed_count >= max_participants
  end

  def confirmed_count
    participations.confirmed.count
  end
end
