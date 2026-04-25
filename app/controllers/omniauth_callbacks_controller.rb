class OmniauthCallbacksController < ApplicationController
  allow_unauthenticated_access

  def google_oauth2
    oauth_login(request.env["omniauth.auth"], "Google")
  end

  def naver
    oauth_login(request.env["omniauth.auth"], "네이버")
  end

  def failure
    redirect_to new_session_path, alert: "소셜 로그인이 취소됐습니다."
  end

  private

  def oauth_login(auth, provider_name)
    user = User.find_or_create_by_oauth(auth)
    if user
      start_new_session_for user
      redirect_to after_authentication_url, notice: "#{provider_name} 계정으로 로그인됐습니다."
    else
      redirect_to new_session_path, alert: "#{provider_name} 로그인에 실패했습니다."
    end
  rescue => e
    Rails.logger.error "OAuth error: #{e.message}"
    redirect_to new_session_path, alert: "#{provider_name} 로그인 중 오류가 발생했습니다."
  end
end
