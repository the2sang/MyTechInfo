class Club < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :club_memberships, dependent: :destroy
  has_many :members, through: :club_memberships, source: :user
  has_many :game_sessions, dependent: :destroy
  has_many :guest_applications, dependent: :destroy

  enum :status, { pending: 0, approved: 1, suspended: 2 }, default: :pending

  normalizes :name,          with: ->(n) { n.strip }
  normalizes :contact_email, with: ->(e) { e.strip.downcase }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :owner, presence: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
