class Export < ApplicationRecord
  belongs_to :user
  enum :status, { queued: "queued", processing: "processing", ready: "ready", failed: "failed" }
  validates :status, presence: true
end
