class Connection < ActiveRecord::Base
  belongs_to :source, :foreign_key => :source_id, :class_name => 'Node'

  belongs_to :target, :foreign_key => :target_id, :class_name => 'Node'
 
  validates_uniqueness_of :source_id, :scope => :target_id

  validates :target_id, :source_id, :presence => true

  #attr_accessible :capacity, :cost, :source_id, :target_id
end
