require "test_helper"

class WorkJournalTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @valid_attrs = {
      title: "API 작업",
      content_format: "markdown",
      category: :task,
      status: :in_progress,
      progress: 50,
      work_date: Date.today,
      entry_type: :result,
      sequence_number: 1
    }
  end

  test "valid with required fields" do
    j = @user.work_journals.new(@valid_attrs)
    assert j.valid?, j.errors.full_messages.inspect
  end

  test "content is optional" do
    j = @user.work_journals.new(@valid_attrs.merge(content: ""))
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

  test "entry_type defaults to result" do
    j = @user.work_journals.new(@valid_attrs.except(:entry_type))
    assert j.valid?
    assert_equal "result", j.entry_type
  end

  test "entry_type enum: result and plan are valid" do
    %i[result plan].each do |type|
      j = @user.work_journals.new(@valid_attrs.merge(entry_type: type))
      assert j.valid?, "expected entry_type=#{type} to be valid"
    end
  end

  test "sequence_number must be at least 1" do
    j = @user.work_journals.new(@valid_attrs.merge(sequence_number: 0))
    assert_not j.valid?
    assert_predicate j.errors[:sequence_number], :present?
  end

  test "sequence_number accepts positive integers" do
    j = @user.work_journals.new(@valid_attrs.merge(sequence_number: 5))
    assert j.valid?, j.errors.full_messages.inspect
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

  test "by_type scope filters by entry_type" do
    result_j = @user.work_journals.create!(@valid_attrs.merge(entry_type: :result))
    plan_j   = @user.work_journals.create!(@valid_attrs.merge(entry_type: :plan, sequence_number: 2))
    assert_includes @user.work_journals.by_type(:result), result_j
    assert_not_includes @user.work_journals.by_type(:result), plan_j
  end

  test "ordered scope sorts by sequence_number" do
    j3 = @user.work_journals.create!(@valid_attrs.merge(sequence_number: 3))
    j1 = @user.work_journals.create!(@valid_attrs.merge(sequence_number: 1))
    j2 = @user.work_journals.create!(@valid_attrs.merge(sequence_number: 2))
    ordered = @user.work_journals.ordered.where(id: [ j1.id, j2.id, j3.id ])
    assert_equal [ j1.id, j2.id, j3.id ], ordered.map(&:id)
  end
end
