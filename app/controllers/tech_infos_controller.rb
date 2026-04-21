class TechInfosController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_tech_info, only: %i[ show edit update destroy ]
  before_action :authorize_tech_info!, only: %i[ edit update destroy ]

  PER_PAGE = 5

  def index
    @page       = [params[:page].to_i, 1].max
    @total      = TechInfo.count
    @total_pages = (@total / PER_PAGE.to_f).ceil
    @tech_infos = TechInfo.includes(:user).recent
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

  def tech_info_params
    params.expect(tech_info: [ :title, :reference_url, :related_tech, :content, :content_format, :extra_info, :usefulness ])
  end
end
