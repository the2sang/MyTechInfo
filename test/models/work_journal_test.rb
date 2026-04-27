require "test_helper"

class WorkJournalTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @valid_attrs = {
      title: "API 작업",
      content: "## 진행\n- 인증 모듈 완료",
      content_format: "markdown",
      category: :task,
      status: :in_progress,
      progress: 50,
      work_date: Date.today
    }
  end

  test "valid with required fields" do
    j = @user.work_journals.new(@valid_attrs)
    assert j.valid?, j.errors.full_messages.inspect
  end

  test "title required" do
    j = @user.work_journals.new(@valid_attrs.merge(title: ""))
    assert_not j.valid?
    assert_predicate j.errors[:title], :present?
  end

  test "title limited to 200 characters" do
    j = @user.work_journals.new(@valid_attrs.merge(title: "x" * 201))
    assert_not j.valid?
    assert_predicate j.errors[:title], :present?
  end

  test "content required" do
    j = @user.work_journals.new(@valid_attrs.merge(content: ""))
    assert_not j.valid?
  end

  test "progress rejects negatives, over 100, and floats" do
    [ -1, 101, 50.5 ].each do |bad|
      j = @user.work_journals.new(@valid_attrs.merge(progress: bad))
      assert_not j.valid?, "expected progress=#{bad} to be invalid"
    end
  end

  test "progress accepts 0 and 100 boundary" do
    [ 0, 100 ].each do |ok|
      j = @user.work_journals.new(@valid_attrs.merge(progress: ok))
      assert j.valid?, "expected progress=#{ok} to be valid"
    end
  end

  test "content_format inclusion limited to markdown/html" do
    j = @user.work_journals.new(@valid_attrs.merge(content_format: "rtf"))
    assert_not j.valid?
  end

  test "work_date required" do
    j = @user.work_journals.new(@valid_attrs.merge(work_date: nil))
    assert_not j.valid?
  end

  test "category and status enums coerce strings" do
    j = @user.work_journals.create!(@valid_attrs)
    assert_equal "task", j.category
    j.update!(status: :completed, category: :meeting)
    assert j.completed?
    assert j.meeting?
  end

  test "for_month returns only journals in the given month" do
    @user.work_journals.create!(@valid_attrs.merge(work_date: Date.new(2026, 4, 15)))
    @user.work_journals.create!(@valid_attrs.merge(work_date: Date.new(2026, 5, 1)))
    result = @user.work_journals.for_month(2026, 4).pluck(:work_date)
    assert_includes result, Date.new(2026, 4, 15)
    assert_not_includes result, Date.new(2026, 5, 1)
  end

  test "for_month boundary: last day included, first of next excluded" do
    @user.work_journals.create!(@valid_attrs.merge(work_date: Date.new(2026, 4, 30)))
    @user.work_journals.create!(@valid_attrs.merge(work_date: Date.new(2026, 5, 1)))
    result = @user.work_journals.for_month(2026, 4).pluck(:work_date)
    assert_includes result, Date.new(2026, 4, 30)
    assert_not_includes result, Date.new(2026, 5, 1)
  end

  test "recent orders by work_date desc then created_at desc" do
    older = @user.work_journals.create!(@valid_attrs.merge(work_date: Date.today - 2))
    newer = @user.work_journals.create!(@valid_attrs.merge(work_date: Date.today))
    ordered = @user.work_journals.recent.where(id: [ older.id, newer.id ])
    assert_equal newer.id, ordered.first.id
  end
end
