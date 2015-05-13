class Timer < ActiveRecord::Base
  validates :time, :project_id, :capacities_matrix_text, :presence => true
  
  #attr_accessible :capacities_matrix_text, :project_id, :time
end
