class AddPathToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :path, :text
  end
end
