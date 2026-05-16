require "test_helper"

class Participations::CreateServiceTest < ActiveSupport::TestCase
  def setup
    @capped   = game_sessions(:open_public_session)   # max_participants: 20
    @uncapped = game_sessions(:members_only_session)  # max_participants: nil
    @user     = users(:one)
  end

  test "creates confirmed when under capacity" do
    result = Participations::CreateService.call(game_session: @capped, user: @user)
    assert result.success?
    assert result.participation.confirmed?
  end

  test "creates confirmed when no capacity limit" do
    result = Participations::CreateService.call(game_session: @uncapped, user: @user)
    assert result.success?
    assert result.participation.confirmed?
  end

  test "creates waitlisted when at capacity" do
    @capped.update!(max_participants: 1)
    Participation.create!(game_session: @capped, user: users(:two), status: :confirmed)
    result = Participations::CreateService.call(game_session: @capped, user: @user)
    assert result.success?
    assert result.participation.waitlisted?
  end

  test "creates confirmed guest participation" do
    result = Participations::CreateService.call(
      game_session: @capped, guest_name: "게스트",
      guest_sport_level: "beginner", guest_region: "서울"
    )
    assert result.success?
    assert result.participation.confirmed?
    assert_nil result.participation.user_id
  end

  test "fails when session is closed" do
    @capped.update!(status: :closed)
    result = Participations::CreateService.call(game_session: @capped, user: @user)
    assert_not result.success?
    assert_includes result.errors, "세션이 마감되었습니다."
  end
end
