class ChangeAslProficiencyToString < ActiveRecord::Migration
  def change
    change_column :users, :asl_proficiency, :string
  end
end