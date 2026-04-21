class TechInfoReactionsController < ApplicationController
  before_action :set_tech_info

  def create
    kind = params[:kind].to_s
    return head :unprocessable_entity unless TechInfoReaction.kinds.key?(kind)

    existing = @tech_info.reactions.find_by(user: Current.session.user)

    if existing
      if existing.kind == kind
        existing.destroy!
      else
        existing.update!(kind: kind)
      end
    else
      @tech_info.reactions.create!(user: Current.session.user, kind: kind)
    end

    render_reaction_stream
  end

  def destroy
    @tech_info.reactions.find_by(user: Current.session.user)&.destroy
    render_reaction_stream
  end

  private

  def set_tech_info
    @tech_info = TechInfo.includes(:reactions).find(params[:tech_info_id])
  end

  def render_reaction_stream
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "tech_info_#{@tech_info.id}_reactions",
          partial: "tech_infos/reactions",
          locals: { tech_info: @tech_info, current_user: Current.session&.user }
        )
      end
    end
  end
end
