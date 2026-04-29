module Admin
  class GroupsController < BaseController
    before_action :set_group, only: %i[show edit update destroy]

    def index
      authorize Group, policy_class: Admin::GroupPolicy
      @groups = Group.includes(:owner, :users).order(created_at: :desc)
    end

    def show
      authorize @group, policy_class: Admin::GroupPolicy
      @members = @group.users.order(:nickname)
    end

    def new
      authorize Group, policy_class: Admin::GroupPolicy
      @group = Group.new
      @users = User.order(:nickname)
    end

    def create
      authorize Group, policy_class: Admin::GroupPolicy
      @group = Group.new(group_params)
      if @group.save
        sync_memberships(@group, Array(params[:group][:user_ids].reject(&:blank?).map(&:to_i)))
        redirect_to admin_group_path(@group), notice: "그룹이 생성되었습니다."
      else
        @users = User.order(:nickname)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @group, policy_class: Admin::GroupPolicy
      @users = User.order(:nickname)
    end

    def update
      authorize @group, policy_class: Admin::GroupPolicy
      if @group.update(group_params)
        sync_memberships(@group, Array(params[:group][:user_ids].reject(&:blank?).map(&:to_i)))
        redirect_to admin_group_path(@group), notice: "그룹이 수정되었습니다."
      else
        @users = User.order(:nickname)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @group, policy_class: Admin::GroupPolicy
      @group.destroy
      redirect_to admin_groups_path, notice: "그룹이 삭제되었습니다."
    end

    private

    def set_group
      @group = Group.find(params[:id])
    end

    def group_params
      params.require(:group).permit(:name, :owner_id)
    end

    def sync_memberships(group, user_ids)
      user_ids << group.owner_id
      user_ids = user_ids.uniq.compact

      existing_ids = group.group_memberships.pluck(:user_id)
      to_add    = user_ids - existing_ids
      to_remove = existing_ids - user_ids

      to_add.each do |uid|
        role = uid == group.owner_id ? :owner : :member
        group.group_memberships.create!(user_id: uid, role: role)
      end
      group.group_memberships.where(user_id: to_remove).destroy_all

      group.group_memberships.where(user_id: group.owner_id).update_all(role: GroupMembership::ROLES[:owner])
    end
  end
end
