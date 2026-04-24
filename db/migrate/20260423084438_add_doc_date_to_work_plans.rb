class AddDocDateToWorkPlans < ActiveRecord::Migration[8.1]
  def change
    add_column :work_plans, :doc_date, :date
    WorkPlan.reset_column_information
    WorkPlan.find_each { |wp| wp.update_column(:doc_date, wp.created_at.to_date) }
    change_column_null :work_plans, :doc_date, false
  end
end
