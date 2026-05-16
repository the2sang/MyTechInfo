module Users
  class SyncDuprRatingJob < ApplicationJob
    queue_as :default

    def perform(user_id)
      user = User.find_by(id: user_id)
      return unless user&.dupr_id.present?

      Users::SyncDuprRatingService.call(user: user)
    end
  end
end
