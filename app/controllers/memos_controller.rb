class MemosController < ApplicationController
  allow_unauthenticated_access only: %i[index]
  before_action :set_memo, only: %i[edit update destroy]
  before_action :authorize_memo!, only: %i[edit update destroy]

  PER_PAGE = 9

  def index
    return unless authenticated?

    @page        = [ params[:page].to_i, 1 ].max
    base         = Current.session.user.memos.recent
    @total       = base.count
    @total_pages = (@total / PER_PAGE.to_f).ceil
    @memos       = base.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
    @new_memo    = Memo.new
  end

  def create
    @memo = Current.session.user.memos.new(memo_params)
    if @memo.save
      redirect_to memos_path, notice: "메모가 등록되었습니다."
    else
      @memos    = Current.session.user.memos.recent.limit(PER_PAGE)
      @new_memo = @memo
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @memo.update(memo_params)
      redirect_to memos_path, notice: "메모가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @memo.destroy
    redirect_to memos_path, notice: "메모가 삭제되었습니다."
  end

  private

  def set_memo
    @memo = Memo.find(params[:id])
  end

  def authorize_memo!
    redirect_to memos_path, alert: "권한이 없습니다." unless authenticated? && Current.session.user == @memo.user
  end

  def memo_params
    params.require(:memo).permit(:title, :content)
  end
end
