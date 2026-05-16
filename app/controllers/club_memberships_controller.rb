class ClubMembershipsController < ApplicationController
  before_action :set_club

  def index
    @membership = ClubMembership.new(club: @club)
    authorize @membership
    @pending  = @club.club_memberships.pending.includes(:user)
    @approved = @club.club_memberships.approved.includes(:user)
  end

  def create
    @membership = @club.club_memberships.build(user: Current.user)
    authorize @membership
    if @membership.save
      redirect_to @club, notice: "가입 신청이 완료되었습니다."
    else
      redirect_to @club, alert: @membership.errors.full_messages.join(", ")
    end
  end

  def update
    @membership = ClubMembership.find(params[:id])
    authorize @membership
    @membership.update!(status: params[:status])
    redirect_back_or_to club_club_memberships_path(@membership.club), notice: "가입 상태가 변경되었습니다."
  end

  def destroy
    @membership = ClubMembership.find(params[:id])
    authorize @membership
    @membership.destroy!
    redirect_back_or_to clubs_path, notice: "탈퇴 처리되었습니다."
  end

  private

  def set_club = @club = Club.find(params[:club_id])
end
