class AddSuccessToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :success, :boolean
  end
end
