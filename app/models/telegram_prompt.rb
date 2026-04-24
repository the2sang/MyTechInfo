class TelegramPrompt < ApplicationRecord
  PENDING = "pending"
  PROCESSING = "processing"
  COMPLETED = "completed"
  FAILED = "failed"

  STATUSES = [ PENDING, PROCESSING, COMPLETED, FAILED ].freeze

  before_validation :set_command

  validates :chat_id, presence: true
  validates :message_text, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :telegram_message_id, uniqueness: { scope: :chat_id, allow_nil: true }

  scope :pending, -> { where(status: PENDING) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_processing!
    update!(status: PROCESSING)
  end

  def mark_completed!(result)
    update!(status: COMPLETED, result: result, error_message: nil, processed_at: Time.current)
  end

  def mark_failed!(error_message)
    update!(status: FAILED, error_message: error_message, processed_at: Time.current)
  end

  private
    def set_command
      self.command = message_text.to_s.split.first if command.blank?
    end
end
