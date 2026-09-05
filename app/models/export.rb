class Export < ApplicationRecord
  belongs_to :user
  belongs_to :plan
  enum :status, { queued: "queued", processing: "processing", ready: "ready", failed: "failed" }
  validates :status, presence: true
end
