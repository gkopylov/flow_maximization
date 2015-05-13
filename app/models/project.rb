require 'push_relable'
require 'dijkstra'

class Project < ActiveRecord::Base
  include PushRelable
  include Dijkstra

  belongs_to :user

  has_many :nodes, :dependent => :destroy

  has_many :requests, :dependent => :destroy

  has_many :timers, :dependent => :destroy

  validates :user_id, :presence => true   
 
  validates :name, :presence => true, :uniqueness => true

  #attr_accessible :name, :user_id

  #@TODO spec me
  def capacities_matrix source_id, target_id, time=false
    capacities = []

    connections_hash, connections_double_hash = connections_hashes time

    matching_array = reorder_nodes connections_hash, source_id, target_id

    connections_hash.each do |source_id, target_array|
      capacities[matching_array[source_id]] = []

      target_array.each do |target_id|
        if source_id.present? && target_id.present? && connections_double_hash[source_id].present?
          capacities[matching_array[source_id]][matching_array[target_id]]= connections_double_hash[source_id][target_id]
        end
      end
    end
    
    capacities.count.times do |i|
      capacities.count.times do |j|
        capacities[i][j] = (capacities[i].present? && capacities[i][j].present?) ? capacities[i][j] : 0
      end
    end

    capacities
  end

  #@TODO spec me
  def costs_graph time=false
    connections_hash = {}

    self.nodes.includes(:nodes).each do |source| 
      connections_hash[source.id] = []

      source.nodes.each do |target|
        connections_hash[source.id] << target.id
      end
    end

    connections = Connection.where(:source_id => connections_hash.keys).
      where(:target_id => connections_hash.values.flatten.uniq)

    connections_double_hash = {}

    if time.present? && (timer=self.timers.where(:time => time).first).present?
      connections_double_hash_capacities = eval(timer.capacities_matrix_text)

      connections.each do |connection|
        if connections_double_hash_capacities[connection.source_id][connection.target_id] > 0
          connections_double_hash[connection.source_id] ||= {}

          connections_double_hash[connection.source_id][connection.target_id] = connection.cost
        end
      end
    else
      connections.each do |connection|
        connections_double_hash[connection.source_id] ||= {}

        connections_double_hash[connection.source_id][connection.target_id] = connection.cost
      end
    end

    connections_double_hash
  end

  def connections_hashes time=false
    connections_hash = {}

    self.nodes.includes(:nodes).each do |source| 
      connections_hash[source.id] = []

      source.nodes.each do |target|
        connections_hash[source.id] << target.id
      end
    end

    connections = Connection.where(:source_id => connections_hash.keys).
      where(:target_id => connections_hash.values.flatten.uniq)

    connections_double_hash = {}

    if (timer = self.timers.where(:time => time).first).present?
      connections_double_hash = eval(timer.capacities_matrix_text)
    else
      connections.each do |connection|
        connections_double_hash[connection.source_id] ||= {}

        connections_double_hash[connection.source_id][connection.target_id] = connection.capacity
      end
    end

    [connections_hash, connections_double_hash]
  end

  def start
    self.reload.timers.destroy_all

    requests.order("start_time ASC").each do |request|
      request.update_attribute :path, ''
      
      request.push_request
    end
  
    self.reload.timers.destroy_all
  end

  private
  def reorder_nodes connections_hash, source_id, target_id
    ordered_hash = (connections_hash.keys + connections_hash.values.flatten).uniq.sort

    counter = 0

    matching_array = {}

    ordered_hash.delete source_id

    ordered_hash.delete target_id

    ordered_hash.insert(0, source_id)

    ordered_hash.insert(-1, target_id)

    ordered_hash.each do |node_id|
      matching_array[node_id] = counter 
    
      counter += 1
    end

    matching_array
  end
end
