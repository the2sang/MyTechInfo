class ClubsController < ApplicationController
  before_action :set_club,      only: %i[show edit update destroy]
  before_action :require_login, only: %i[new create edit update destroy]

  def index
    @clubs = policy_scope(Club).order(:name)
  end

  def show
    authorize @club
    @game_sessions = policy_scope(GameSession).where(club: @club).order(scheduled_date: :desc)
  end

  def new
    @club = Club.new
    authorize @club
  end

  def create
    @club = Club.new(club_params.merge(owner: Current.user, status: :pending))
    authorize @club
    if @club.save
      @club.club_memberships.create!(user: Current.user, role: :manager, status: :approved)
      redirect_to @club, notice: "동호회 개설 신청이 완료되었습니다. 관리자 승인 후 활성화됩니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @club
  end

  def update
    authorize @club
    if @club.update(club_params)
      redirect_to @club, notice: "동호회 정보가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @club
    @club.destroy!
    redirect_to clubs_path, notice: "동호회가 삭제되었습니다."
  end

  private

  def set_club = @club = Club.find(params[:id])
  def club_params = params.require(:club).permit(:name, :description)
  def require_login = redirect_to(new_session_path) unless Current.user
end
