class AddWorkEndAtToWorkPlans < ActiveRecord::Migration[8.1]
  def change
    add_column :work_plans, :work_end_at, :datetime
  end
end
