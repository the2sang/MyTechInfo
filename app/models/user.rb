class User < ApplicationRecord
  has_secure_password validations: false
  has_many :sessions, dependent: :destroy
  has_many :identities, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :tech_infos, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :tech_info_reactions, dependent: :destroy
  has_many :memos, dependent: :destroy
  has_many :work_plans,  dependent: :destroy
  has_many :life_infos,  dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :nickname, with: ->(n) { n.strip }

  validates :email_address, presence: true,
                            uniqueness: { case_sensitive: false },
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :nickname, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { minimum: 2, maximum: 30 }
  validates :password, length: { minimum: 8 }, allow_nil: true

  def self.find_or_create_by_oauth(auth)
    identity = Identity.find_by(provider: auth.provider, uid: auth.uid)
    return identity.user if identity

    user = find_by(email_address: auth.info.email) ||
           create!(
             email_address: auth.info.email,
             nickname: generate_unique_nickname(auth.info.name || auth.info.email.split("@").first),
             password: nil
           )
    user.identities.create!(provider: auth.provider, uid: auth.uid)
    user
  rescue ActiveRecord::RecordNotUnique
    Identity.find_by(provider: auth.provider, uid: auth.uid)&.user
  end

  def self.generate_unique_nickname(base)
    base = base.gsub(/[^a-zA-Z0-9가-힣_]/, "").first(28).presence || "user"
    return base unless exists?(nickname: base)
    (2..99).each { |n| return "#{base}#{n}" unless exists?(nickname: "#{base}#{n}") }
    "#{base}#{SecureRandom.hex(3)}"
  end
end
