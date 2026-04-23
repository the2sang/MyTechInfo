module Telegram
  class WebhooksController < ApplicationController
    allow_unauthenticated_access
    skip_forgery_protection only: :create

    before_action :verify_webhook_secret!

    def create
      message = telegram_message
      return head :ok if message.blank?
      return head :ok if message["text"].blank?

      chat_id = message.dig("chat", "id").to_s
      return head :ok unless allowed_chat?(chat_id)

      prompt = TelegramPrompt.find_or_create_by!(
        chat_id: chat_id,
        telegram_message_id: message["message_id"]
      ) do |record|
        record.message_text = message["text"].to_s
        record.command = command_from(message["text"])
      end

      TelegramPromptJob.perform_later(prompt) if prompt.pending?

      head :ok
    end

    private
      def telegram_message
        update = params.to_unsafe_h
        update["message"] || update["edited_message"]
      end

      def command_from(text)
        text.to_s.split.first
      end

      def verify_webhook_secret!
        configured_secret =
          telegram_credential(:webhook_secret).presence || ENV["TELEGRAM_WEBHOOK_SECRET"].presence

        if configured_secret.blank?
          return unless Rails.env.production?

          Rails.logger.warn("Telegram webhook rejected because TELEGRAM_WEBHOOK_SECRET is not configured")
          return head :unauthorized
        end

        header_secret = request.headers["X-Telegram-Bot-Api-Secret-Token"].to_s
        return if ActiveSupport::SecurityUtils.secure_compare(header_secret, configured_secret)

        head :unauthorized
      end

      def allowed_chat?(chat_id)
        allowed_chat_ids = Array(telegram_credential(:allowed_chat_ids)).map(&:to_s)
        allowed_chat_ids += ENV.fetch("TELEGRAM_ALLOWED_CHAT_IDS", "").split(",").map(&:strip)
        allowed_chat_ids = allowed_chat_ids.reject(&:blank?)

        return true if allowed_chat_ids.empty? && !Rails.env.production?
        return true if allowed_chat_ids.include?(chat_id)

        Rails.logger.warn("Telegram webhook rejected unauthorized chat_id=#{chat_id}")
        false
      end

      def telegram_credential(key)
        Rails.application.credentials.dig(:telegram, key)
      end
  end
end
