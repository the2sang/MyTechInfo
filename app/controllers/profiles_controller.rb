class ProfilesController < ApplicationController
  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    dupr_id_changed = params.dig(:user, :dupr_id).to_s != @user.dupr_id.to_s

    if @user.update(profile_params.merge(profile_completed_at: Time.current))
      Users::SyncDuprRatingJob.perform_later(@user.id) if dupr_id_changed && @user.dupr_id.present?
      redirect_to(session.delete(:return_to) || root_path, notice: "프로필이 저장되었습니다.")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:display_name, :sport_level, :gender, :age_group, :region, :dupr_id)
  end
end
