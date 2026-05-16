class ParticipationsController < ApplicationController
  before_action :set_game_session

  def new
    if @game_session.members_only? && Current.user.nil?
      redirect_to new_session_path, alert: "로그인이 필요한 세션입니다."
      return
    end
    @participation = Participation.new
    authorize @participation
  end

  def create
    @participation = Participation.new
    authorize @participation

    result = Participations::CreateService.call(
      game_session:      @game_session,
      user:              Current.user,
      guest_name:        params.dig(:participation, :guest_name),
      guest_sport_level: params.dig(:participation, :guest_sport_level),
      guest_region:      params.dig(:participation, :guest_region)
    )

    if result.success?
      msg = result.participation.waitlisted? ? "대기열에 등록되었습니다." : "참가 신청이 완료되었습니다."
      redirect_to game_session_path(@game_session), notice: msg
    else
      flash.now[:alert] = result.errors.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_game_session = @game_session = GameSession.find(params[:game_session_id])
end
