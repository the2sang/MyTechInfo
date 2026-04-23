require "test_helper"

class TelegramPromptJobTest < ActiveJob::TestCase
  test "marks a prompt completed and sends the result" do
    prompt = telegram_prompts(:one)
    delivered = []

    Telegram::Client.stub(:new, fake_client(delivered)) do
      TelegramPromptJob.perform_now(prompt)
    end

    prompt.reload
    assert_equal TelegramPrompt::COMPLETED, prompt.status
    assert_includes prompt.result, "개발 작업 요청을 접수했습니다"
    assert_equal [ prompt.chat_id ], delivered.map { |message| message[:chat_id] }
  end

  private
    def fake_client(delivered)
      Object.new.tap do |client|
        client.define_singleton_method(:send_message) do |chat_id:, text:|
          delivered << { chat_id: chat_id, text: text }
          true
        end
      end
    end
end
