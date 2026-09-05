class Task < ApplicationRecord
  XP_VALUE = 25

  belongs_to :goal
  belongs_to :plan
  belongs_to :user
  has_many :xp_entries, dependent: :restrict_with_exception

  validates :title, presence: true, length: { maximum: 180 }

  def complete!
    return if completed_at.present?
    transaction do
      update!(completed_at: Time.current)
      xp_entries.create!(user: user, plan: plan, points: XP_VALUE, kind: "completion")
    end
  end

  def reopen!
    return if completed_at.blank?
    transaction do
      update!(completed_at: nil)
      xp_entries.create!(user: user, plan: plan, points: -XP_VALUE, kind: "reversal")
    end
  end
end
