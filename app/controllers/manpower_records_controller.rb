class ManpowerRecordsController < ApplicationController
  before_action :set_manpower_record, only: %i[update destroy]

  def index
    authorize ManpowerRecord
    @year  = params[:year]&.to_i  || Date.today.year
    @month = params[:month]&.to_i || Date.today.month
    @calendar_date = Date.new(@year, @month, 1)

    records = policy_scope(ManpowerRecord).for_month(@year, @month)
    @records_by_date = records.by_request_date.group_by(&:request_date)
  rescue Date::Error
    redirect_to manpower_records_path
  end

  def create
    @manpower_record = Current.session.user.manpower_records.new(manpower_record_params)
    authorize @manpower_record

    if @manpower_record.save
      @request_date = @manpower_record.request_date
      @records = Current.session.user.manpower_records
                        .where(request_date: @request_date)
                        .by_request_date
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to manpower_records_path }
      end
    else
      @request_date = @manpower_record.request_date || Date.today
      render turbo_stream: turbo_stream.replace(
        "mp-form-#{@request_date.iso8601}",
        partial: "form",
        locals: { manpower_record: @manpower_record }
      ), status: :unprocessable_entity
    end
  end

  def update
    authorize @manpower_record

    if @manpower_record.update(manpower_record_params)
      @request_date = @manpower_record.request_date
      @records = Current.session.user.manpower_records
                        .where(request_date: @request_date)
                        .by_request_date
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to manpower_records_path }
      end
    else
      render turbo_stream: turbo_stream.replace(
        "mp-form-#{@manpower_record.request_date.iso8601}",
        partial: "form",
        locals: { manpower_record: @manpower_record }
      ), status: :unprocessable_entity
    end
  end

  def destroy
    authorize @manpower_record
    date = @manpower_record.request_date
    @manpower_record.destroy
    @request_date = date
    @records = Current.session.user.manpower_records
                      .where(request_date: @request_date)
                      .by_request_date
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to manpower_records_path }
    end
  end

  private

  def set_manpower_record
    @manpower_record = ManpowerRecord.find(params[:id])
  end

  def manpower_record_params
    params.require(:manpower_record).permit(
      :request_date, :start_date, :end_date, :work_minutes, :description
    )
  end
end
