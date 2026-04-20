class TechInfosController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_tech_info, only: %i[ show edit update destroy ]
  before_action :authorize_tech_info!, only: %i[ edit update destroy ]

  def index
    @tech_infos = TechInfo.includes(:user).recent
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

  private

  def set_tech_info
    @tech_info = TechInfo.find(params[:id])
  end

  def authorize_tech_info!
    redirect_to root_path, alert: "권한이 없습니다." unless @tech_info.user == Current.session.user
  end

  def tech_info_params
    params.expect(tech_info: [ :title, :reference_url, :related_tech, :content, :content_format, :extra_info, :usefulness ])
  end
end
