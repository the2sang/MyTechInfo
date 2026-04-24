class StockInfosController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :require_authenticated, only: %i[destroy]
  before_action :set_stock_info,        only: %i[show destroy]

  def index
    @stock_infos = StockInfo.recent.limit(60)
  end

  def show
  end

  def destroy
    @stock_info.destroy
    redirect_to stock_infos_path, notice: "삭제되었습니다."
  end

  private

  def set_stock_info
    @stock_info = StockInfo.find(params[:id])
  end
end
