module Participations
  class CancelService
    Result = Struct.new(:success?, :errors, keyword_init: true)

    def self.call(participation:) = new(participation: participation).call

    def initialize(participation:)
      @participation = participation
    end

    def call
      was_confirmed = @participation.confirmed?
      @participation.cancelled!
      promote_waitlist if was_confirmed
      Result.new(success?: true, errors: [])
    end

    private

    def promote_waitlist
      next_in_line = @participation.game_session
                                   .participations
                                   .waitlisted
                                   .order(:created_at)
                                   .first
      next_in_line&.confirmed!
    end
  end
end
