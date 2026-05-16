require "test_helper"

class GameSessionTest < ActiveSupport::TestCase
  def setup
    @club = clubs(:approved_club)
    @session = GameSession.new(
      club:           @club,
      title:          "토요 운동",
      venue_name:     "올림픽공원 코트",
      scheduled_date: Date.today + 7,
      start_time:     "10:00",
      end_time:       "12:00"
    )
  end

  test "valid with required fields" do
    assert @session.valid?
  end

  test "invalid without title" do
    @session.title = nil
    assert_not @session.valid?
  end

  test "default visibility is public_visibility" do
    assert @session.public_visibility?
  end

  test "default status is open" do
    assert @session.open?
  end

  test "full? returns true when confirmed count meets max_participants" do
    @session.max_participants = 0
    assert @session.full?
  end

  test "full? returns false when max_participants is nil" do
    @session.max_participants = nil
    assert_not @session.full?
  end
end
