namespace :stock_infos do
  KOREAN_DAYS = %w[일 월 화 수 목 금 토].freeze

  desc "Fetch today's stock market outlook via Claude CLI and save to DB"
  task fetch: :environment do
    claude_prompt = ENV.fetch("STOCK_QUERY", "오늘의 국내외 주식 시장 전망을 분석해줘. KOSPI, KOSDAQ, NASDAQ, S&P500의 주요 이슈와 투자 포인트를 포함해서 요약해줘.")

    today = Time.current
    day_name = KOREAN_DAYS[today.wday]
    title = "오늘의 주식전망 (#{today.strftime('%Y-%m-%d')}(#{day_name}))"

    puts "Querying Claude CLI..."
    begin
      result = Timeout.timeout(60) do
        `claude -p "#{claude_prompt}" 2>&1`
      end

      if $CHILD_STATUS.success? && result.present?
        StockInfo.create!(
          query:      title,
          content:    result.strip,
          queried_at: today
        )
        puts "StockInfo saved: #{title} (#{result.length} chars)"
      else
        warn "Claude CLI returned an error: #{result}"
        exit 1
      end
    rescue Timeout::Error
      warn "Claude CLI timed out after 60 seconds."
      exit 1
    rescue StandardError => e
      warn "Unexpected error: #{e.message}"
      exit 1
    end
  end
end
