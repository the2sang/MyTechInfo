class Group < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships

  validates :name, presence: true, length: { maximum: 100 }
end
