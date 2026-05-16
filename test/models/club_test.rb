require "test_helper"

class ClubTest < ActiveSupport::TestCase
  def setup
    @owner = users(:one)
    @club  = Club.new(name: "서울클럽", owner: @owner)
  end

  test "valid with name and owner" do
    assert @club.valid?
  end

  test "invalid without name" do
    @club.name = nil
    assert_not @club.valid?
    assert @club.errors[:name].any?
  end

  test "name must be unique" do
    @club.save!
    dup = Club.new(name: "서울클럽", owner: @owner)
    assert_not dup.valid?
  end

  test "default status is pending" do
    assert @club.pending?
  end

  test "status enum includes pending approved suspended" do
    assert_equal %w[pending approved suspended], Club.statuses.keys
  end
end
