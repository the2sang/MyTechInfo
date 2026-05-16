require "test_helper"

class Clubs::AssignManagerByEmailServiceTest < ActiveSupport::TestCase
  def setup
    @user  = User.create!(email_address: "manager@example.com", nickname: "mgr", password: "password123")
    @owner = User.create!(email_address: "owner@example.com",   nickname: "owner", password: "password123")
    @club  = Club.create!(name: "테스트 동호회", owner: @owner, contact_email: "manager@example.com", status: :approved)
  end

  test "user로 호출 시 email 일치하는 동호회의 관리자로 지정" do
    Clubs::AssignManagerByEmailService.call(user: @user)
    m = ClubMembership.find_by(user: @user, club: @club)
    assert m, "멤버십이 생성되어야 함"
    assert_equal "manager", m.role
    assert_equal "approved", m.status
  end

  test "club으로 호출 시 contact_email 일치하는 유저를 관리자로 지정" do
    Clubs::AssignManagerByEmailService.call(club: @club)
    m = ClubMembership.find_by(user: @user, club: @club)
    assert m, "멤버십이 생성되어야 함"
    assert_equal "manager", m.role
    assert_equal "approved", m.status
  end

  test "이미 멤버인 경우 role을 manager로 업그레이드" do
    ClubMembership.create!(user: @user, club: @club, role: :member, status: :approved)
    Clubs::AssignManagerByEmailService.call(user: @user)
    assert_equal "manager", ClubMembership.find_by(user: @user, club: @club).role
  end

  test "contact_email 없는 동호회는 건너뜀" do
    club2 = Club.create!(name: "이메일없는 동호회", owner: @owner, status: :approved)
    assert_no_difference "ClubMembership.count" do
      Clubs::AssignManagerByEmailService.call(club: club2)
    end
  end

  test "매칭 유저 없으면 멤버십 생성 안 함" do
    @club.update!(contact_email: "nobody@example.com")
    assert_no_difference "ClubMembership.count" do
      Clubs::AssignManagerByEmailService.call(club: @club)
    end
  end
end
