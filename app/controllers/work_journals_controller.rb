class WorkJournalsController < ApplicationController
  before_action :set_work_journal, only: %i[show edit update destroy]

  def index
    authorize WorkJournal
    year  = params[:year]&.to_i  || Date.today.year
    month = params[:month]&.to_i || Date.today.month
    @calendar_date = Date.new(year, month, 1)

    @viewed_user   = resolve_viewed_user
    @group_members = Current.session.user.group_members.order(:nickname)
    journals = policy_scope(WorkJournal).where(user: @viewed_user).for_month(year, month)
    @journals_by_date = journals.group_by(&:work_date)
  rescue Date::Error
    redirect_to work_journals_path
  end

  def show
    authorize @work_journal
  end

  def new
    authorize WorkJournal
    @date = parse_date_param || Date.today
    user  = Current.session.user
    @result_entries = user.work_journals.for_date(@date).result.ordered
    @plan_entries   = user.work_journals.for_date(@date).plan.ordered
    @work_journal   = WorkJournal.new(
      work_date:      @date,
      content_format: "markdown",
      category:       :task,
      status:         :in_progress,
      progress:       0
    )
  end

  def create
    @work_journal = Current.session.user.work_journals.new(work_journal_params)
    @work_journal.sequence_number = next_sequence(
      Current.session.user,
      @work_journal.work_date,
      @work_journal.entry_type
    )
    if @work_journal.save
      @date = @work_journal.work_date
      user  = Current.session.user
      @result_entries = user.work_journals.for_date(@date).result.ordered
      @plan_entries   = user.work_journals.for_date(@date).plan.ordered
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to new_work_journal_path(date: @date), notice: "항목이 추가되었습니다." }
      end
    else
      @date = @work_journal.work_date || Date.today
      user  = Current.session.user
      @result_entries = user.work_journals.for_date(@date).result.ordered
      @plan_entries   = user.work_journals.for_date(@date).plan.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @work_journal
  end

  def update
    authorize @work_journal
    if @work_journal.update(work_journal_params)
      redirect_to work_journal_path(@work_journal), notice: "업무일지가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @work_journal
    date = @work_journal.work_date
    @work_journal.destroy
    redirect_to new_work_journal_path(date: date), notice: "항목이 삭제되었습니다."
  end

  private

  def set_work_journal
    @work_journal = WorkJournal.find(params[:id])
  end

  def resolve_viewed_user
    return Current.session.user if params[:member_id].blank?

    current_user = Current.session.user
    member = current_user.group_members.find_by(id: params[:member_id])
    member || current_user
  end

  def parse_date_param
    Date.parse(params[:date]) if params[:date].present?
  rescue Date::Error
    nil
  end

  def next_sequence(user, date, type)
    return 1 if date.blank? || type.blank?

    user.work_journals.where(work_date: date, entry_type: type).count + 1
  end

  def work_journal_params
    params.require(:work_journal).permit(
      :title, :content, :content_format,
      :category, :status, :progress, :work_date, :entry_type
    )
  end
end
