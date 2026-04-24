class TechInfo < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :reactions, class_name: "TechInfoReaction", dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }
  validates :content, presence: true
  validates :usefulness, presence: true, inclusion: { in: 1..5 }
  validates :content_format, presence: true, inclusion: { in: %w[markdown html] }
  validates :reference_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true

  scope :recent,      -> { order(created_at: :desc) }
  scope :public_only, -> { where(is_public: true) }
  scope :search, ->(query, date_from, date_to) {
    conds, vals = [], []
    if query.present?
      conds << "(title LIKE ? OR content LIKE ?)"
      vals  << "%#{query}%" << "%#{query}%"
    end
    if date_from.present? && date_to.present?
      conds << "DATE(created_at) BETWEEN ? AND ?"; vals << date_from << date_to
    elsif date_from.present?
      conds << "DATE(created_at) >= ?"; vals << date_from
    elsif date_to.present?
      conds << "DATE(created_at) <= ?"; vals << date_to
    end
    conds.empty? ? all : where(conds.join(" OR "), *vals)
  }

  def related_tech_list
    related_tech.to_s.split(",").map(&:strip).reject(&:blank?)
  end
end
