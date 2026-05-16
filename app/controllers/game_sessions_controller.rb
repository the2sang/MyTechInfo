class GameSessionsController < ApplicationController
  before_action :set_club,         only: %i[new create]
  before_action :set_game_session, only: %i[show edit update destroy]

  def index
    @game_sessions = policy_scope(GameSession).order(scheduled_date: :desc)
  end

  def show
    authorize @game_session
  end

  def new
    @game_session = @club.game_sessions.build
    authorize @game_session
  end

  def create
    @game_session = @club.game_sessions.build(game_session_params)
    authorize @game_session
    if @game_session.save
      redirect_to @game_session, notice: "세션이 등록되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @game_session
  end

  def update
    authorize @game_session
    if @game_session.update(game_session_params)
      redirect_to @game_session, notice: "세션이 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @game_session
    club = @game_session.club
    @game_session.destroy!
    redirect_to club_path(club), notice: "세션이 삭제되었습니다."
  end

  private

  def set_club = @club = Club.find(params[:club_id])
  def set_game_session = @game_session = GameSession.find(params[:id])

  def game_session_params
    params.require(:game_session).permit(
      :title, :venue_name, :address, :scheduled_date,
      :start_time, :end_time, :court_count, :fee, :notes,
      :max_participants, :visibility, :status
    )
  end
end
