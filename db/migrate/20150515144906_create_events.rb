class CreateEvents < ActiveRecord::Migration
def change
    create_table :events do |t|
      t.string :name
      t.string :location
      t.datetime :start_datetime
      t.integer :event_type_id
 
      t.timestamps null: false
    end
  end
end
