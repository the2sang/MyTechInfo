class TelegramPromptJob < ApplicationJob
  queue_as :default

  discard_on ActiveJob::DeserializationError

  def perform(telegram_prompt)
    telegram_prompt.mark_processing!

    result = Telegram::PromptProcessor.new(telegram_prompt).call
    telegram_prompt.mark_completed!(result)

    notify(telegram_prompt.chat_id, result)
  rescue StandardError => error
    telegram_prompt.mark_failed!(error.message) if telegram_prompt&.persisted?
    notify(telegram_prompt.chat_id, "Telegram 작업 처리에 실패했습니다: #{error.message}") \
      if telegram_prompt&.chat_id.present?
    raise
  end

  private
    def notify(chat_id, text)
      Telegram::Client.new.send_message(chat_id: chat_id, text: text)
    rescue StandardError => error
      Rails.logger.warn("Telegram notification failed: #{error.class}: #{error.message}")
    end
end
