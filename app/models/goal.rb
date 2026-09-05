class Goal < ApplicationRecord
  belongs_to :plan
  belongs_to :user
  has_many :tasks, -> { order(:created_at) }, dependent: :destroy

  validates :title, presence: true, length: { maximum: 160 }
end
