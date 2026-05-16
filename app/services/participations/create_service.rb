module Participations
  class CreateService
    Result = Struct.new(:success?, :participation, :errors, keyword_init: true)

    def self.call(**args) = new(**args).call

    def initialize(game_session:, user:, participation_type: :as_member)
      @game_session       = game_session
      @user               = user
      @participation_type = participation_type
    end

    def call
      return failure("세션이 마감되었습니다.") unless @game_session.open?

      status = @game_session.full? ? :waitlisted : :confirmed
      participation = @game_session.participations.build(
        user:               @user,
        participation_type: @participation_type,
        status:             status
      )

      if participation.save
        Result.new(success?: true, participation: participation, errors: [])
      else
        Result.new(success?: false, participation: participation,
                   errors: participation.errors.full_messages)
      end
    end

    private

    def failure(message)
      Result.new(success?: false, participation: nil, errors: [ message ])
    end
  end
end
