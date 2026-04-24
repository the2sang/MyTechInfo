class LifeInfo < ApplicationRecord
  belongs_to :user

  validates :title,          presence: true, length: { maximum: 200 }
  validates :content,        presence: true
  validates :content_format, presence: true, inclusion: { in: %w[html markdown] }
  validates :reference_url,  format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "유효한 URL을 입력하세요" }, allow_blank: true

  scope :recent,      -> { order(created_at: :desc) }
  scope :public_only, -> { where(is_public: true) }
end
