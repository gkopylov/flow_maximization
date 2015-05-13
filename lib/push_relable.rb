require 'active_support/concern'

module PushRelable
  extend ActiveSupport::Concern

  included do
    def max_flow source_id, target_id, time=false
      capacities_matrix = self.capacities_matrix source_id, target_id, time

      obj = PushRelable::Base.new capacities_matrix
  
      obj.count_max_flow
    end
  end

  class Base
    INIFINITE = 10000

    attr_accessor :capacities, :flow, :nodes, :height, :excess, :list, :seen

    def initialize capacities
      @capacities = capacities
   
      @flow = Array.new(capacities.size) { |i| Array.new(capacities.first.size) { |i| 0 }}

      @nodes = capacities.first.size

      @height = Array.new(@capacities.first.size) { |i| 0 }
      
      @excess = Array.new(@capacities.first.size) { |i| 0 }

      @list = Array.new(@capacities.first.size) { |i| 0 }

      @seen = Array.new(@capacities.first.size) { |i| 0 }
    end

    def count_max_flow
      (@nodes - 2).times { |i| @list[i] = i + 1 }

      @height[0] = @nodes

      @excess[0] = INIFINITE

      @nodes.times { |i| push(0, i) }

      p = 0

      while (p < @nodes - 2)
        u = @list[p]

        old_height = @height[u]

        discharge u 

        if height[u] > old_height
          move_to_front p

          p = 0
        else
          p += 1
        end
      end

      maxflow = 0

      @nodes.times { |i| maxflow += @flow[0][i] }

      maxflow
    end

    private
    def push u, v
      send = [@excess[u], @capacities[u][v] - @flow[u][v]].min

      @flow[u][v] += send

      @flow[v][u] -= send

      @excess[u] -= send

      @excess[v] += send
    end

    def relable u
      min_height = INIFINITE

      @nodes.times do |v|
        if @capacities[u][v] - @flow[u][v] > 0
          min_height = [min_height, @height[v]].min

          @height[u] = min_height + 1
        end
      end
    end

    def discharge u
      while @excess[u] > 0 
        if @seen[u] < @nodes 
          v = @seen[u]
      
          if ((@capacities[u][v] - @flow[u][v] > 0) && (@height[u] > @height[v])) 
            push(u, v)
          else
            @seen[u] += 1
          end
        else
          relable u

          @seen[u] = 0
        end
      end
    end

    def move_to_front p
      value = @list.delete_at p

      @list.unshift value
    end
  end
end
