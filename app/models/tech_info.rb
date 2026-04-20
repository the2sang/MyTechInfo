class TechInfo < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }
  validates :content, presence: true
  validates :usefulness, presence: true, inclusion: { in: 1..5 }
  validates :content_format, presence: true, inclusion: { in: %w[markdown html] }
  validates :reference_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true

  scope :recent, -> { order(created_at: :desc) }

  def related_tech_list
    related_tech.to_s.split(",").map(&:strip).reject(&:blank?)
  end
end
