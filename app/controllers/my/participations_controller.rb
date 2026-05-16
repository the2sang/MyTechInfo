module My
  class ParticipationsController < ApplicationController
    def index
      @participations = Current.user.participations.includes(:game_session).order(created_at: :desc)
    end

    def destroy
      @participation = Current.user.participations.find(params[:id])
      authorize @participation
      Participations::CancelService.call(participation: @participation)
      redirect_to my_participations_path, notice: "참가 신청이 취소되었습니다."
    end
  end
end
