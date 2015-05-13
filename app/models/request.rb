# encoding: utf-8

class Request < ActiveRecord::Base
  belongs_to :source, :foreign_key => :source_id, :class_name => 'Node'

  belongs_to :target, :foreign_key => :target_id, :class_name => 'Node'

  belongs_to :project

  validates :target_id, :source_id, :presence => true

  validates :start_time, :lifetime, :size, :presence => true, 
    :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  validate :source_and_target_validation

  #attr_accessible :lifetime, :size, :source_id, :target_id, :project_id, :start_time, :success, :path

  #@TODO spec me
  def push_request
    if (project.max_flow source_id, target_id, start_time) < size
      update_attribute :success, false
    else
      request_size = self.size

      while request_size > 0
        timer = Timer.where(:time => start_time, :project_id => project.id).first_or_create

        if timer.capacities_matrix_text.present?
          capacities_matrix = eval(timer.capacities_matrix_text)
        else
          capacities_matrix = (project.connections_hashes start_time).last

          timer.capacities_matrix_text = capacities_matrix.to_s
        end

        timer.save
        
        best_path = project.best_path source_id, target_id, start_time

        capacities_matrix = eval((timer = project.timers.where(:time => self.start_time).first).capacities_matrix_text)

        min_capacity = []

        best_path.each_cons(2).to_a.each do |source_id, target_id|
          min_capacity << capacities_matrix[source_id][target_id] 
        end
  
        min_capacity = min_capacity.min

        min_capacity = min_capacity > request_size ? request_size : min_capacity
       
        (self.start_time..(self.start_time + self.lifetime - 1)).each do |time|
          timer = Timer.where(:time => time, :project_id => project.id).first_or_create

          if timer.capacities_matrix_text.present?
            capacities_matrix = eval(timer.capacities_matrix_text)
          else
            capacities_matrix = (project.connections_hashes time).last
          end
        
          best_path.each_cons(2).to_a.each do |source_id, target_id|
            capacities_matrix[source_id][target_id] -= min_capacity 
          end

          timer.capacities_matrix_text = capacities_matrix.to_s

          timer.save
        end

        update_attribute :path, path.to_s + best_path.to_s

        request_size -= min_capacity
      end

      update_attribute :success, true
    end
  end

  private
  def source_and_target_validation
    if source_id == target_id
      errors.add(:source_id, 'Источник и сток не могут быть одиниковы')
    end
  end
end
