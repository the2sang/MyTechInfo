class Participation < ApplicationRecord
  belongs_to :game_session
  belongs_to :user

  enum :status,             { confirmed: 0, waitlisted: 1, cancelled: 2 }, default: :confirmed
  enum :participation_type, { as_member: 0, as_guest: 1 }, default: :as_member

  validates :user_id, uniqueness: { scope: :game_session_id, message: "이미 신청한 세션입니다." }

  scope :active, -> { where(status: [ :confirmed, :waitlisted ]) }

  def display_name
    user.display_name.presence || user.nickname
  end
end
