class LifeInfosController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :set_life_info,        only: %i[show edit update destroy]
  before_action :require_authenticated, only: %i[new create edit update destroy]
  before_action :authorize_life_info!,  only: %i[edit update destroy]
  before_action :require_public_or_authenticated!, only: %i[show]

  PER_PAGE = 12

  def index
    @life_infos = base_scope
                    .then { |s| params[:q].present? ? s.where("title LIKE ?", "%#{params[:q]}%") : s }
                    .then { |s| params[:category].present? ? s.where(category: params[:category]) : s }
                    .recent
    @categories  = LifeInfo.public_only.distinct.pluck(:category).compact.sort
    @page        = (params[:page] || 1).to_i
    @total       = @life_infos.count
    @life_infos  = @life_infos.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def show
  end

  def new
    @life_info = LifeInfo.new(content_format: "html")
  end

  def create
    @life_info = Current.session.user.life_infos.new(life_info_params)
    if @life_info.save
      redirect_to life_info_path(@life_info), notice: "생활정보가 등록되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @life_info.update(life_info_params)
      redirect_to life_info_path(@life_info), notice: "생활정보가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @life_info.destroy
    redirect_to life_infos_path, notice: "생활정보가 삭제되었습니다."
  end

  private

  def set_life_info
    @life_info = LifeInfo.find(params[:id])
  end

  def authorize_life_info!
    redirect_to life_infos_path, alert: "권한이 없습니다." unless Current.session.user == @life_info.user
  end

  def require_public_or_authenticated!
    return if @life_info.is_public
    return if authenticated? && Current.session.user == @life_info.user

    redirect_to life_infos_path, alert: "접근 권한이 없습니다."
  end

  def base_scope
    authenticated? ? LifeInfo.all : LifeInfo.public_only
  end

  def life_info_params
    params.require(:life_info).permit(:title, :content, :content_format, :category, :reference_url, :is_public)
  end
end
