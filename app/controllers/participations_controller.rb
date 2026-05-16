class ParticipationsController < ApplicationController
  before_action :set_game_session
  before_action :require_authentication
  before_action :require_profile!, only: %i[new create]

  def new
    @membership = Current.user.club_memberships.find_by(club: @game_session.club)
    @participation_type = resolve_participation_type(@membership)
    @participation = Participation.new
    authorize @participation
  end

  def create
    @participation = Participation.new
    authorize @participation

    participation_type = params.dig(:participation, :participation_type) || :as_member

    result = Participations::CreateService.call(
      game_session:       @game_session,
      user:               Current.user,
      participation_type: participation_type
    )

    if result.success?
      msg = result.participation.waitlisted? ? "대기열에 등록되었습니다." : "참가 신청이 완료되었습니다."
      redirect_to game_session_path(@game_session), notice: msg
    else
      flash.now[:alert] = result.errors.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @participation = @game_session.participations.find(params[:id])
    authorize @participation
    Participations::CancelService.call(participation: @participation)
    redirect_to game_session_path(@game_session), notice: "참가 신청이 취소되었습니다."
  end

  private

  def set_game_session = @game_session = GameSession.find(params[:game_session_id])

  def require_profile!
    return if Current.user.profile_complete?

    session[:return_to] = request.fullpath
    redirect_to edit_profile_path, alert: "참가 신청 전에 기본 정보를 등록해 주세요."
  end

  def resolve_participation_type(membership)
    membership&.approved? ? :as_member : :as_guest
  end
end
