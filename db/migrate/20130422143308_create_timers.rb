class CreateTimers < ActiveRecord::Migration
  def change
    create_table :timers do |t|
      t.integer :project_id, :null => false
      t.integer :time, :null =>false
      t.text :capacities_matrix_text, :null => false

      t.timestamps
    end

    add_index :timers, :project_id
    add_index :timers, :time
  end
end
