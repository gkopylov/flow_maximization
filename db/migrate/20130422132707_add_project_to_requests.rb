class AddProjectToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :project_id, :integer, :null => false

    add_index :requests, :project_id
  end
end
