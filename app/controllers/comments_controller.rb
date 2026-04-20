class CommentsController < ApplicationController
  before_action :set_tech_info

  def create
    @comment = @tech_info.comments.build(comment_params)
    @comment.user = Current.session.user
    if @comment.save
      redirect_to @tech_info, notice: "댓글이 등록되었습니다."
    else
      redirect_to @tech_info, alert: @comment.errors.full_messages.first
    end
  end

  def destroy
    @comment = @tech_info.comments.find(params[:id])
    authorize_comment!
    @comment.destroy
    redirect_to @tech_info, notice: "댓글이 삭제되었습니다."
  end

  private

  def set_tech_info
    @tech_info = TechInfo.find(params[:tech_info_id])
  end

  def authorize_comment!
    redirect_to @tech_info, alert: "권한이 없습니다." unless @comment.user == Current.session.user
  end

  def comment_params
    params.expect(comment: [ :body ])
  end
end
