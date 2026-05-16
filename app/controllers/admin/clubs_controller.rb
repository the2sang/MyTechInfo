module Admin
  class ClubsController < ApplicationController
    def index
      authorize [ :admin, Club.new ]
      @approved_clubs  = Club.approved.includes(:owner).order(:name)
      @suspended_clubs = Club.suspended.includes(:owner).order(:name)
    end

    def show
      @club = Club.find(params[:id])
      authorize [ :admin, @club ]
      @memberships = @club.club_memberships.includes(:user)
    end

    def update
      @club = Club.find(params[:id])
      authorize [ :admin, @club ]
      @club.update!(status: params[:status])
      redirect_to admin_clubs_path, notice: "동호회 상태가 변경되었습니다."
    end
  end
end
