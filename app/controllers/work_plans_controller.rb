class WorkPlansController < ApplicationController
  before_action :set_work_plan, only: %i[show edit update destroy hwpx]

  def index
    authorize WorkPlan
    year  = params[:year]&.to_i  || Date.today.year
    month = params[:month]&.to_i || Date.today.month
    @calendar_date = Date.new(year, month, 1)

    @viewed_user    = resolve_viewed_user
    @group_members  = Current.session.user.group_members.order(:nickname)
    plans = policy_scope(WorkPlan).where(user: @viewed_user).for_month(year, month)
    @plans_by_date = plans.group_by { |wp| wp.work_at.to_date }
    @department_names = @viewed_user.work_plans.distinct.pluck(:department_name)
    @holidays = KoreanHolidays.for_month(year, month)
  end

  def show
    authorize @work_plan
  end

  def hwpx
    authorize @work_plan
    data     = WorkPlans::HwpxGeneratorService.call(@work_plan)
    filename = "작업계획서_#{@work_plan.work_at.strftime('%Y%m%d')}_#{@work_plan.work_name}.hwpx"
    send_data data,
      type:        "application/hwp+zip",
      disposition: "attachment",
      filename:    filename
  end

  def new
    authorize WorkPlan
    @work_plan = WorkPlan.new(
      doc_date: Date.today,
      work_end_at: Time.current.change(min: 0, sec: 0)
    )
    if params[:date].present?
      @work_plan.work_at = Date.parse(params[:date])
    end
  rescue Date::Error
    @work_plan = WorkPlan.new(doc_date: Date.today)
  end

  def create
    authorize WorkPlan
    @work_plan = Current.session.user.work_plans.new(work_plan_params)
    if @work_plan.save
      redirect_to work_plans_path, notice: "작업계획서가 등록되었습니다."
    else
      @department_names = Current.session.user.work_plans.distinct.pluck(:department_name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @work_plan
    @department_names = Current.session.user.work_plans.distinct.pluck(:department_name)
  end

  def update
    authorize @work_plan
    if @work_plan.update(work_plan_params)
      redirect_to work_plan_path(@work_plan), notice: "작업계획서가 수정되었습니다."
    else
      @department_names = Current.session.user.work_plans.distinct.pluck(:department_name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @work_plan
    @work_plan.destroy
    redirect_to work_plans_path, notice: "작업계획서가 삭제되었습니다."
  end

  private

  def set_work_plan
    @work_plan = WorkPlan.find(params[:id])
  end

  def resolve_viewed_user
    return Current.session.user if params[:member_id].blank?

    current_user = Current.session.user
    member = current_user.group_members.find_by(id: params[:member_id])
    member || current_user
  end

  def work_plan_params
    params.require(:work_plan).permit(:department_name, :doc_date, :work_name, :work_at, :work_end_at, :work_content, :extra_info)
  end
end
