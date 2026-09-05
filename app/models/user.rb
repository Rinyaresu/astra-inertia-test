class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :plans, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :check_ins, dependent: :destroy
  has_many :xp_entries, dependent: :destroy
  has_many :exports, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true

  def xp_total
    xp_entries.sum(:points)
  end

  def level
    (xp_total / 100) + 1
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
