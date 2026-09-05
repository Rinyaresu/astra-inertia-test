class CheckIn < ApplicationRecord
  belongs_to :plan
  belongs_to :user
  validates :reflection, presence: true, length: { maximum: 1_000 }
  validates :checked_in_on, presence: true
end
