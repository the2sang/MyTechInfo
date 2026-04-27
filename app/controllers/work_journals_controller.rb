class WorkJournalsController < ApplicationController
  before_action :set_work_journal, only: %i[show edit update destroy]
  before_action :authorize_work_journal!, only: %i[show edit update destroy]

  def index
    year  = params[:year]&.to_i  || Date.today.year
    month = params[:month]&.to_i || Date.today.month
    @calendar_date = Date.new(year, month, 1)
    journals = Current.session.user.work_journals.for_month(year, month)
    @journals_by_date = journals.group_by(&:work_date)
  rescue Date::Error
    redirect_to work_journals_path
  end

  def show
  end

  def new
    @work_journal = WorkJournal.new(
      work_date:      parse_date_param || Date.today,
      content_format: "markdown",
      category:       :task,
      status:         :in_progress,
      progress:       0
    )
  end

  def create
    @work_journal = Current.session.user.work_journals.new(work_journal_params)
    if @work_journal.save
      redirect_to work_journals_path, notice: "업무일지가 등록되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @work_journal.update(work_journal_params)
      redirect_to work_journal_path(@work_journal), notice: "업무일지가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @work_journal.destroy
    redirect_to work_journals_path, notice: "업무일지가 삭제되었습니다."
  end

  private

  def set_work_journal
    @work_journal = WorkJournal.find(params[:id])
  end

  def authorize_work_journal!
    return if Current.session.user == @work_journal.user

    redirect_to work_journals_path, alert: "권한이 없습니다."
  end

  def parse_date_param
    Date.parse(params[:date]) if params[:date].present?
  rescue Date::Error
    nil
  end

  def work_journal_params
    params.require(:work_journal).permit(
      :title, :content, :content_format,
      :category, :status, :progress, :work_date
    )
  end
end
