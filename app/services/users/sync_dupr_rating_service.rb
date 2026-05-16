module Users
  class SyncDuprRatingService
    DUPR_API_BASE = "https://backend.mydupr.com"

    Result = Struct.new(:success?, :rating, :error, keyword_init: true)

    def self.call(user:) = new(user:).call

    def initialize(user:)
      @user = user
    end

    def call
      return Result.new(success?: false, error: "DUPR ID가 없습니다.") if @user.dupr_id.blank?

      bearer_token = ENV["DUPR_BEARER_TOKEN"] || Rails.application.credentials.dig(:dupr, :bearer_token)
      return Result.new(success?: false, error: "DUPR API 토큰이 설정되지 않았습니다.") if bearer_token.blank?

      response = fetch_player(bearer_token)

      if response[:success]
        rating = response[:rating]
        @user.update_columns(dupr_rating: rating, dupr_last_synced_at: Time.current)
        Result.new(success?: true, rating: rating)
      else
        Result.new(success?: false, error: response[:error])
      end
    rescue => e
      Rails.logger.error("[SyncDuprRatingService] #{e.class}: #{e.message}")
      Result.new(success?: false, error: "DUPR 연동 중 오류가 발생했습니다.")
    end

    private

    def fetch_player(bearer_token)
      uri = URI("#{DUPR_API_BASE}/player/v1.0/search")
      uri.query = URI.encode_www_form(query: @user.dupr_id, pageSize: 1)

      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{bearer_token}"
      req["Accept"] = "application/json"
      req["Content-Type"] = "application/json"

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }

      if response.is_a?(Net::HTTPSuccess)
        parse_rating(JSON.parse(response.body))
      else
        { success: false, error: "DUPR API 오류 (#{response.code})" }
      end
    end

    def parse_rating(body)
      players = body.dig("result", "hits") || body["result"] || []
      return { success: false, error: "DUPR ID를 찾을 수 없습니다." } if players.empty?

      player = players.first
      rating = player["ratings"]&.dig("singles", "displayRating") ||
               player["ratings"]&.dig("doubles", "displayRating") ||
               player["rating"]

      return { success: false, error: "DUPR 레이팅 정보를 가져올 수 없습니다." } if rating.blank?

      { success: true, rating: rating.to_f }
    end
  end
end
