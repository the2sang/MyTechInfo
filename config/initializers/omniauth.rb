Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           Rails.application.credentials.dig(:google, :client_id),
           Rails.application.credentials.dig(:google, :client_secret),
           scope: "email,profile"

  provider :naver,
           Rails.application.credentials.dig(:naver, :client_id),
           Rails.application.credentials.dig(:naver, :client_secret)
end

OmniAuth.config.logger = Rails.logger
