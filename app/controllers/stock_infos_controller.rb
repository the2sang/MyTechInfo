class StockInfosController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :require_authenticated, only: %i[destroy]
  before_action :set_stock_info,        only: %i[show destroy]

  PER_PAGE = 12

  def index
    @search_query     = params[:q].to_s.strip
    @search_date_from = params[:date_from].to_s.strip
    @search_date_to   = params[:date_to].to_s.strip
    @page             = [ params[:page].to_i, 1 ].max

    base         = StockInfo.recent.search(@search_query, @search_date_from, @search_date_to)
    @total       = base.count
    @total_pages = (@total / PER_PAGE.to_f).ceil
    @stock_infos = base.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
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
