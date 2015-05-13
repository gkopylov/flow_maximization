require 'active_support/concern'

module Dijkstra
  extend ActiveSupport::Concern

  included do
    def best_path source, target, time=false
      obj = Dijkstra::Base.new (self.costs_graph time), source, target
  
      obj.count_best_path
    end
  end

  class Base
    attr_accessor :source, :target, :vertices, :costs_graph, :distances

    def initialize costs_graph, source, target
      @costs_graph = costs_graph

      @source = source

      @target = target
    
      @vertices = []

      costs_graph.each do |k, v|
        @vertices << k

        v.each do |k2, v2|
          @vertices << k2
        end 
      end
  
      @distances = {}

      @vertices = @vertices.uniq

      @vertices.each do |vertice|
        @distances[vertice] = Float::INFINITY 
      end

      @distances[@source] = 0
    end

    def count_best_path
      path = {}

      vertices_set = @vertices

      while vertices_set.size > 0
        vertice = @distances.min_by(&:last).first

        vertices_set.delete(vertice)

        break if @distances[vertice] == Float::INFINITY || vertice == target

        if @costs_graph.key? vertice
          @costs_graph[vertice].each do |next_vertice, cost|
            if (distances.key? vertice) && (distances.key? next_vertice)
              sum_cost = distances[vertice] + cost

              if sum_cost < distances[next_vertice]
                @distances[next_vertice] = sum_cost

                path[next_vertice] = vertice
              end
            end
          end
        end

        @distances.delete vertice
      end
        
      result = []

      target = @target

      result << target
      while path.key? target 
        result << path[target] if path[target]

        target = path[target]
      end

      result.reverse
    end
  end
end
