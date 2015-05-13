class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.integer :project_id, :null => false
      t.string :name
      t.integer :left, :default => 0
      t.integer :top, :default => 0

      t.timestamps
    end

    add_index :nodes, :project_id
  end
end
