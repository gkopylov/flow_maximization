class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :size, :default => 10, :null => false
      t.integer :source_id, :null => false
      t.integer :target_id, :null => false
      t.integer :lifetime, :default => 10, :null => false

      t.timestamps
    end

    add_index :requests, :lifetime
    add_index :requests, [:source_id, :target_id]
    add_index :requests, :target_id
  end
end
