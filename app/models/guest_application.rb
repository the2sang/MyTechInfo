class GuestApplication < ApplicationRecord
  belongs_to :club

  enum :status, { pending: 0, contacted: 1, done: 2, rejected: 3 }, default: :pending

  validates :name,  presence: true
  validates :phone, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
