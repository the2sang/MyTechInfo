require "test_helper"

class ClubMembershipTest < ActiveSupport::TestCase
  def setup
    @club = clubs(:approved_club)
    @user = users(:one)
  end

  test "valid with club and user" do
    membership = ClubMembership.new(club: @club, user: @user)
    assert membership.valid?
  end

  test "cannot join same club twice" do
    ClubMembership.create!(club: @club, user: @user)
    dup = ClubMembership.new(club: @club, user: @user)
    assert_not dup.valid?
  end

  test "default role is member and status is pending" do
    m = ClubMembership.new(club: @club, user: @user)
    assert m.member?
    assert m.pending?
  end
end
