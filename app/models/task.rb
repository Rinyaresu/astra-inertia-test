class Task < ApplicationRecord
  XP_VALUE = 25

  belongs_to :goal
  belongs_to :plan
  belongs_to :user
  has_many :xp_entries, dependent: :restrict_with_exception

  validates :title, presence: true, length: { maximum: 180 }

  def complete!
    with_lock do
      return if completed_at.present?
      update!(completed_at: Time.current)
      xp_entries.create!(user: user, plan: plan, points: XP_VALUE, kind: "completion")
    end
  end

  def reopen!
    with_lock do
      return if completed_at.blank?
      update!(completed_at: nil)
      xp_entries.create!(user: user, plan: plan, points: -XP_VALUE, kind: "reversal")
    end
  end
end
