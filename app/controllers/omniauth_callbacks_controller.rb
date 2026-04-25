class OmniauthCallbacksController < ApplicationController
  allow_unauthenticated_access

  def google_oauth2
    user = User.find_or_create_by_oauth(request.env["omniauth.auth"])
    if user
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Google 계정으로 로그인됐습니다."
    else
      redirect_to new_session_path, alert: "Google 로그인에 실패했습니다. 다시 시도해 주세요."
    end
  rescue => e
    Rails.logger.error "OAuth error: #{e.message}"
    redirect_to new_session_path, alert: "Google 로그인 중 오류가 발생했습니다."
  end

  def failure
    redirect_to new_session_path, alert: "Google 로그인이 취소됐습니다."
  end
end
