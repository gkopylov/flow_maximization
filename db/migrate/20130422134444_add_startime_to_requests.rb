class AddStartimeToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :start_time, :integer, :null => false, :default => 0

    add_index :requests, :start_time
  end
end
