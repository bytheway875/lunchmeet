class CreateUsers < ActiveRecord::Migration
 def change
    create_table :users do |t|
      t.string :name
      t.string :cell_phone
      t.integer :asl_proficiency
 
      t.timestamps null: false
    end
  end
end
