class XpEntry < ApplicationRecord
  belongs_to :user
  belongs_to :plan
  belongs_to :task

  validates :kind, inclusion: { in: %w[completion reversal] }
  validates :points, inclusion: { in: [ -Task::XP_VALUE, Task::XP_VALUE ] }
  before_validation :set_event_id, on: :create
  before_validation :sign_entry, on: :create
  before_update { raise ActiveRecord::ReadOnlyRecord, "XP history is immutable" }
  before_destroy { raise ActiveRecord::ReadOnlyRecord, "XP history is immutable" }

  def signature_valid?
    payload = [ event_id, user_id, plan_id, task_id, points, kind ].join(":")
    ActiveSupport::SecurityUtils.secure_compare(signature, OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, payload))
  end

  private
    def set_event_id
      self.event_id = SecureRandom.uuid if event_id.blank?
    end

    def sign_entry
      return if signature.present?
      payload = [ event_id, user_id, plan_id, task_id, points, kind ].join(":")
      self.signature = OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, payload)
    end
end
