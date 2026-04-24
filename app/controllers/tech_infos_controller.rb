class TechInfosController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_tech_info, only: %i[ show edit update destroy ]
  before_action :authorize_tech_info!, only: %i[ edit update destroy ]

  before_action :require_public_or_authenticated!, only: %i[ show ]

  PER_PAGE = 10

  def index
    @search_query     = params[:q].to_s.strip
    @search_date_from = params[:date_from].to_s.strip
    @search_date_to   = params[:date_to].to_s.strip
    @page             = [ params[:page].to_i, 1 ].max

    base = (authenticated? ? TechInfo.all : TechInfo.public_only)
             .search(@search_query, @search_date_from, @search_date_to)

    @total       = base.count
    @total_pages = (@total / PER_PAGE.to_f).ceil
    @tech_infos  = base.includes(:user).recent
                       .limit(PER_PAGE)
                       .offset((@page - 1) * PER_PAGE)
  end

  def show
  end

  def new
    @tech_info = TechInfo.new
  end

  def edit
  end

  def create
    @tech_info = Current.session.user.tech_infos.build(tech_info_params)
    if @tech_info.save
      redirect_to @tech_info, notice: "기술정보가 등록되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @tech_info.update(tech_info_params)
      redirect_to @tech_info, notice: "기술정보가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tech_info.destroy
    redirect_to tech_infos_path, notice: "기술정보가 삭제되었습니다."
  end

  def export
    json = ::TechInfos::ExportService.call(user: Current.session.user, ids: params[:ids])
    filename = "tech_infos_#{Date.today.strftime('%Y%m%d')}.json"
    send_data json, filename: filename, type: "application/json", disposition: "attachment"
  end

  def import
    result = ::TechInfos::ImportService.call(file: params[:import_file], user: Current.session.user)

    if result.errors.any?
      redirect_to tech_infos_path, alert: result.errors.first
    else
      redirect_to tech_infos_path, notice: "#{result.imported}건 가져옴, #{result.skipped}건 건너뜀"
    end
  end

  private

  def set_tech_info
    @tech_info = TechInfo.includes(:reactions).find(params[:id])
  end

  def authorize_tech_info!
    redirect_to root_path, alert: "권한이 없습니다." unless @tech_info.user == Current.session.user
  end

  def require_public_or_authenticated!
    return if authenticated?
    return if @tech_info.is_public?

    redirect_to tech_infos_path, alert: "로그인이 필요합니다."
  end

  def tech_info_params
    params.require(:tech_info).permit(:title, :reference_url, :related_tech, :content, :content_format, :extra_info, :usefulness, :is_public)
  end
end
