class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.integer :user_id, :null => false
      t.string :name, :null => false

      t.timestamps
    end

    add_index :projects, :name, :unique => true
    add_index :projects, :user_id
  end
end
