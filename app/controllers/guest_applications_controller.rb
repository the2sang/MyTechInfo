class GuestApplicationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  before_action :set_club

  def new
    @guest_application = @club.guest_applications.build
  end

  def create
    @guest_application = @club.guest_applications.build(guest_params)
    if @guest_application.save
      redirect_to club_path(@club),
        notice: "참가 신청이 완료되었습니다. 담당자가 연락드리겠습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_club = @club = Club.find(params[:club_id])

  def guest_params
    params.require(:guest_application).permit(:name, :phone, :email, :message)
  end
end
