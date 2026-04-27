require "test_helper"

class WorkJournalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user        = users(:one)
    @other_user  = users(:two)
    @journal     = work_journals(:one_today)
    @other_journal = work_journals(:two_today)
    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "index renders successfully" do
    get work_journals_url
    assert_response :success
  end

  test "index handles invalid year/month gracefully" do
    get work_journals_url(year: 9999, month: 13)
    assert_redirected_to work_journals_path
  end

  test "unauthenticated user is redirected from index" do
    delete session_url
    get work_journals_url
    assert_redirected_to new_session_url
  end

  test "new prefills work_date from ?date param" do
    get new_work_journal_url(date: "2026-04-15")
    assert_response :success
    assert_select "input[name='work_journal[work_date]'][value='2026-04-15']"
  end

  test "new with invalid date param falls back to today" do
    get new_work_journal_url(date: "garbage")
    assert_response :success
    assert_select "input[name='work_journal[work_date]'][value='#{Date.today}']"
  end

  test "create with valid params" do
    assert_difference("WorkJournal.count") do
      post work_journals_url, params: { work_journal: {
        title: "신규 일지", content: "내용", content_format: "markdown",
        category: "task", status: "in_progress", progress: 30,
        work_date: Date.today.to_s
      } }
    end
    assert_redirected_to work_journals_path
  end

  test "create with invalid params re-renders new" do
    assert_no_difference("WorkJournal.count") do
      post work_journals_url, params: { work_journal: {
        title: "", content: "", content_format: "markdown",
        category: "task", status: "in_progress", progress: 30,
        work_date: Date.today.to_s
      } }
    end
    assert_response :unprocessable_entity
  end

  test "show renders own journal" do
    get work_journal_url(@journal)
    assert_response :success
  end

  test "show redirects when accessing another user's journal" do
    get work_journal_url(@other_journal)
    assert_redirected_to work_journals_path
    assert_equal "권한이 없습니다.", flash[:alert]
  end

  test "edit renders own journal" do
    get edit_work_journal_url(@journal)
    assert_response :success
  end

  test "edit redirects when editing another user's journal" do
    get edit_work_journal_url(@other_journal)
    assert_redirected_to work_journals_path
  end

  test "update with valid params" do
    patch work_journal_url(@journal), params: { work_journal: { progress: 80 } }
    assert_redirected_to work_journal_path(@journal)
    assert_equal 80, @journal.reload.progress
  end

  test "update with invalid params re-renders edit" do
    patch work_journal_url(@journal), params: { work_journal: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "update cannot modify another user's journal" do
    patch work_journal_url(@other_journal), params: { work_journal: { title: "해킹" } }
    assert_redirected_to work_journals_path
    assert_not_equal "해킹", @other_journal.reload.title
  end

  test "destroy deletes own journal" do
    assert_difference("WorkJournal.count", -1) do
      delete work_journal_url(@journal)
    end
    assert_redirected_to work_journals_path
  end

  test "destroy cannot delete another user's journal" do
    assert_no_difference("WorkJournal.count") do
      delete work_journal_url(@other_journal)
    end
    assert_redirected_to work_journals_path
  end

  test "show sanitizes script tags in markdown content" do
    @journal.update!(content: "# Title\n\n<script>alert('xss')</script>\n\nbody text")
    get work_journal_url(@journal)
    assert_response :success
    assert_no_match(/<script>alert/, response.body)
    assert_match(/body text/, response.body)
  end

  test "create with category and status string params persists correctly" do
    post work_journals_url, params: { work_journal: {
      title: "회의록", content: "내용", content_format: "markdown",
      category: "meeting", status: "completed", progress: 100,
      work_date: Date.today.to_s
    } }
    j = WorkJournal.order(:id).last
    assert_equal "meeting", j.category
    assert_equal "completed", j.status
    assert_equal 100, j.progress
  end
end
