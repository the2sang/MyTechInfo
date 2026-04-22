class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :tech_infos, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :tech_info_reactions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :nickname, with: ->(n) { n.strip }

  validates :email_address, presence: true,
                            uniqueness: { case_sensitive: false },
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :nickname, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { minimum: 2, maximum: 30 }
  validates :password, length: { minimum: 8 }, allow_nil: true
end
