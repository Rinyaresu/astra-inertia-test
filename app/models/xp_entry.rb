class XpEntry < ApplicationRecord
  belongs_to :user
  belongs_to :plan
  belongs_to :task

  validates :kind, inclusion: { in: %w[completion reversal] }
  validates :points, inclusion: { in: [-Task::XP_VALUE, Task::XP_VALUE] }
  before_validation :sign_entry, on: :create
  before_update { raise ActiveRecord::ReadOnlyRecord, "XP history is immutable" }
  before_destroy { raise ActiveRecord::ReadOnlyRecord, "XP history is immutable" }

  private
    def sign_entry
      return if signature.present?
      payload = [user_id, plan_id, task_id, points, kind, created_at&.utc&.iso8601].join(":")
      self.signature = OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, payload)
    end
end
