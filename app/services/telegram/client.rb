require "net/http"

module Telegram
  class Client
    API_HOST = "api.telegram.org"

    def initialize(token: nil)
      @token = token.presence || telegram_credential(:bot_token).presence || ENV["TELEGRAM_BOT_TOKEN"].presence
    end

    def send_message(chat_id:, text:)
      return false if token.blank?

      uri = URI::HTTPS.build(host: API_HOST, path: "/bot#{token}/sendMessage")
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = { chat_id: chat_id, text: text }.to_json

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      response.is_a?(Net::HTTPSuccess)
    end

    private
      attr_reader :token

      def telegram_credential(key)
        Rails.application.credentials.dig(:telegram, key)
      end
  end
end
