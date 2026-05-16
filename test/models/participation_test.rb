require "test_helper"

class ParticipationTest < ActiveSupport::TestCase
  def setup
    @session = game_sessions(:open_public_session)
    @user    = users(:one)
  end

  test "valid member participation" do
    p = Participation.new(game_session: @session, user: @user)
    assert p.valid?
  end

  test "valid guest participation" do
    p = Participation.new(
      game_session:      @session,
      guest_name:        "홍길동",
      guest_sport_level: 0,
      guest_region:      "서울"
    )
    assert p.valid?
  end

  test "invalid without game_session" do
    p = Participation.new(user: @user)
    assert_not p.valid?
  end

  test "member cannot join same session twice" do
    Participation.create!(game_session: @session, user: @user, status: :confirmed)
    dup = Participation.new(game_session: @session, user: @user)
    assert_not dup.valid?
  end

  test "guest participation requires guest_name" do
    p = Participation.new(game_session: @session, guest_region: "서울")
    assert_not p.valid?
    assert_includes p.errors[:base], "회원 또는 게스트 정보가 필요합니다."
  end
end
