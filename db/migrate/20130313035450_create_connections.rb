class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer :capacity, :default => 10
      t.integer :source_id, :null => false
      t.integer :target_id, :null => false

      t.timestamps
    end

    add_index :connections, [:source_id, :target_id], :unique => true
    add_index :connections, :target_id
  end
end
