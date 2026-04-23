require "test_helper"

class Telegram::WebhooksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @old_secret = ENV["TELEGRAM_WEBHOOK_SECRET"]
    @old_chat_ids = ENV["TELEGRAM_ALLOWED_CHAT_IDS"]
    ENV["TELEGRAM_WEBHOOK_SECRET"] = "telegram-secret"
    ENV["TELEGRAM_ALLOWED_CHAT_IDS"] = "12345"
  end

  teardown do
    ENV["TELEGRAM_WEBHOOK_SECRET"] = @old_secret
    ENV["TELEGRAM_ALLOWED_CHAT_IDS"] = @old_chat_ids
  end

  test "creates a prompt and enqueues the job for an allowed chat" do
    assert_difference("TelegramPrompt.count") do
      assert_enqueued_with(job: TelegramPromptJob) do
        post telegram_webhook_url,
          params: telegram_update,
          as: :json,
          headers: { "X-Telegram-Bot-Api-Secret-Token" => "telegram-secret" }
      end
    end

    assert_response :success
    prompt = TelegramPrompt.recent.first
    assert_equal "12345", prompt.chat_id
    assert_equal "/task", prompt.command
  end

  test "rejects an invalid webhook secret" do
    assert_no_difference("TelegramPrompt.count") do
      post telegram_webhook_url,
        params: telegram_update,
        as: :json,
        headers: { "X-Telegram-Bot-Api-Secret-Token" => "wrong" }
    end

    assert_response :unauthorized
  end

  test "ignores messages from chats that are not allowed" do
    assert_no_difference("TelegramPrompt.count") do
      post telegram_webhook_url,
        params: telegram_update(chat_id: 999),
        as: :json,
        headers: { "X-Telegram-Bot-Api-Secret-Token" => "telegram-secret" }
    end

    assert_response :success
  end

  private
    def telegram_update(chat_id: 12345)
      {
        update_id: 1,
        message: {
          message_id: 99,
          text: "/task 로그인 화면을 고쳐줘",
          chat: { id: chat_id }
        }
      }
    end
end
