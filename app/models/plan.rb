class Plan < ApplicationRecord
  STATUSES = %w[active paused completed].freeze

  belongs_to :user
  has_many :goals, -> { order(:position, :created_at) }, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :check_ins, dependent: :destroy
  has_many :xp_entries, dependent: :destroy
  has_many :exports, dependent: :destroy

  validates :title, presence: true, length: { maximum: 120 }
  validates :start_date, :end_date, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :end_date_after_start_date

  def progress
    return 0 if tasks.empty?
    ((tasks.where.not(completed_at: nil).count.to_f / tasks.count) * 100).round
  end

  def completed_tasks
    tasks.where.not(completed_at: nil).count
  end

  private
    def end_date_after_start_date
      errors.add(:end_date, "deve ser depois do início") if start_date && end_date && end_date < start_date
    end
end
