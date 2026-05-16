class Participation < ApplicationRecord
  belongs_to :game_session
  belongs_to :user, optional: true

  enum :status,            { confirmed: 0, waitlisted: 1, cancelled: 2 }, default: :confirmed
  enum :guest_sport_level, { beginner: 0, intermediate: 1, advanced: 2, pro: 3 },
       default: :beginner, prefix: :guest

  validate :member_or_guest_present
  validates :user_id, uniqueness: { scope: :game_session_id, allow_nil: true,
                                    message: "이미 신청한 세션입니다." }

  scope :active, -> { where(status: [ :confirmed, :waitlisted ]) }

  private

  def member_or_guest_present
    return if user_id.present? || guest_name.present?
    errors.add(:base, "회원 또는 게스트 정보가 필요합니다.")
  end
end
