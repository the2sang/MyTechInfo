module Telegram
  class PromptProcessor
    def initialize(prompt)
      @prompt = prompt
    end

    def call
      case command
      when "/help", "/start"
        help_message
      when "/status"
        status_message
      when "/review"
        <<~TEXT.strip
          리뷰 요청을 접수했습니다.
          현재 MVP는 요청 저장과 큐 처리를 담당합니다.
          실제 코드 리뷰 실행기는 다음 단계에서 Codex CLI 또는 GitHub PR workflow로 연결합니다.
        TEXT
      when "/ship"
        <<~TEXT.strip
          배포/PR 준비 요청을 접수했습니다.
          자동 실행 전에는 테스트, 변경 파일, 커밋 범위를 확인하는
          승인 단계를 붙이는 구성이 안전합니다.
        TEXT
      else
        task_message
      end
    end

    private
      attr_reader :prompt

      def command
        prompt.command.to_s
      end

      def help_message
        <<~TEXT.strip
          사용할 수 있는 명령:
          /status - Telegram 작업 큐 상태 확인
          /task 내용 - 개발 작업 요청 접수
          /review 내용 - 코드 리뷰 요청 접수
          /ship 내용 - 테스트/커밋/PR 준비 요청 접수
        TEXT
      end

      def status_message
        pending_count = TelegramPrompt.pending.count
        recent = TelegramPrompt.recent.limit(5).pluck(:id, :status, :command)
        recent_lines = recent.map { |id, status, command| "##{id} #{status} #{command}" }

        ([ "대기 중인 Telegram 작업: #{pending_count}" ] + recent_lines).join("\n")
      end

      def task_message
        <<~TEXT.strip
          개발 작업 요청을 접수했습니다.
          요청 번호: ##{prompt.id}

          이 MVP는 Telegram 요청을 Rails에 저장하고 Solid Queue에서 처리합니다.
          실제 코드 수정까지 자동 진행하려면 다음 단계로 Codex CLI 실행기나
          GitHub Issue/PR 생성기를 연결하면 됩니다.
        TEXT
      end
  end
end
