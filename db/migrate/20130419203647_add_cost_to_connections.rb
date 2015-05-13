class AddCostToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :cost, :integer, :default => 10, :null => false
  end
end
