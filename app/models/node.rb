class Node < ActiveRecord::Base
  belongs_to :project
 
  has_many :connections, :foreign_key => :source_id, :dependent => :destroy

  has_many :requests, :foreign_key => :source_id, :dependent => :destroy

  has_many :nodes, :through => :connections, :source => :target

  validates :project_id, :presence => true
end
