require 'rubygems'
require 'pry'
require 'ox'
require 'open3'
require 'daemons'
require 'slop'
require 'gruff'
require_relative './dijkstra'
require_relative './push_relable'

class Object
  def try(*a, &b)
    if a.empty? && block_given?
      yield self
    else
      __send__(*a, &b)
    end
  end
end

class NilClass
  def try(*args)
    nil
  end
end

class ProjectEngine
  attr_accessor :capacities, :costs_graph, :timers, :nodes, :requests, :results

  def initialize capacities, costs_graph, requests
    @capacities = capacities

    @costs_graph = costs_graph

    @requests = requests

    @timers = []
  end

  def start 
    requests.each_with_index do |request, index|
      push request, index
    end
  end

  def push request, index
    if (max_flow request[:source], request[:target], request[:start_time]) < request[:size]
      request[:success] = false
    else
      request_size = request[:size]

      while request_size > 0
        capacities_matrix = timers[request[:start_time]]

        if capacities_matrix.nil?
          capacities_matrix = (connections_hashes request[:start_time]).last

          timers[request[:start_time]] = capacities_matrix
        end

        best_path = get_best_path request[:source], request[:target], request[:start_time]

        best_path.unshift request[:source] if best_path.size == 1

        min_capacity = []

        best_path.each_cons(2).to_a.each do |source_id, target_id|
          min_capacity << capacities_matrix[source_id][target_id] 
        end

        min_capacity = min_capacity.min

        min_capacity = min_capacity > request_size ? request_size : min_capacity
       
        (request[:start_time]..(request[:start_time] + request[:lifetime] - 1)).each do |time|
          capacities_matrix = timers[time]

          capacities_matrix = (connections_hashes time).last if capacities_matrix.nil?
        
          best_path.each_cons(2).to_a.each do |source_id, target_id|
            capacities_matrix[source_id][target_id] -= min_capacity 
          end

          timers[time] = capacities_matrix
        end

        request[:path] = request[:path].to_s + best_path.to_s

        request_size -= min_capacity
      end

      request[:success] = true

      requests[index] = request
    end
  end

  def get_best_path source, target, time
    (Dijkstra::Base.new (get_costs_graph time), source, target).count_best_path
  end

  def max_flow source, target, time
    (PushRelable::Base.new (get_capacities_matrix source, target, time)).count_max_flow
  end

  def get_capacities_matrix source, target, time
    capacities = []
    
    connections_hash, connections_double_hash = connections_hashes time

    matching_array = reorder_nodes connections_hash, source, target

    connections_hash.each do |source_id, target_array|
      capacities[matching_array[source_id]] = []

      target_array.each do |target_id|
        unless source_id.nil? || target_id.nil? || connections_double_hash[source_id].nil?
          capacities[matching_array[source_id]][matching_array[target_id]]= connections_double_hash[source_id][target_id]
        end
      end
    end
    
    capacities.count.times do |i|
      capacities.count.times do |j|
        capacities[i][j] = (!capacities[i].nil? && !capacities[i][j].nil?) ? capacities[i][j] : 0
      end
    end

    capacities
  end

  def connections_hashes time
    connections_hash = {}

    self.capacities.each_with_index do |row, i| 
      connections_hash[i] = []

      row.each_with_index do |capacity, j|
        if capacity > 0
          connections_hash[i] << j
        end
      end
    end
    
    connections_double_hash = timers[time]

    if connections_double_hash.nil?
      connections_double_hash = {}

      self.capacities.each_with_index do |row, i|
        row.each_with_index do |capacity, j|
          if capacity > 0
            connections_double_hash[i] ||= {}

            connections_double_hash[i][j] = capacity
          end
        end
      end
    end

    [connections_hash, connections_double_hash]
  end

  def get_costs_graph time
    connections_double_hash = {}

    capacities_double_hash = timers[time]

    if !capacities_double_hash.nil? 
      self.capacities.each_with_index do |row, i|
        row.each_with_index do |capacity, j|
          if (!capacities_double_hash[i].nil? && !capacities_double_hash[i][j].nil? && 
            capacities_double_hash[i][j] > 0 && !self.costs_graph[i][j].nil?)

            connections_double_hash[i] ||= {}

            connections_double_hash[i][j] = self.costs_graph[i][j]
          end
        end
      end
    else
      connections_double_hash = self.costs_graph
    end

    connections_double_hash
  end

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

  def summary_capacities_vector
    timers.map { |capacities_hash| capacities_hash.try(:values).to_a.map {|i| i.values.inject(&:+)}.inject(&:+).to_i }
  end

  def min_capacity_vector
    timers.map { |capacities_hash| capacities_hash.try(:values).to_a.map {|i| i.values.min}.min.to_i }
  end

  def max_capacity_vector
    timers.map { |capacities_hash| capacities_hash.try(:values).to_a.map {|i| i.values.max}.max.to_i }
  end

  def avg_capacity_vector
    timers.map do |capacities_hash| 
      capacities_hash.try(:values).to_a.map {|i| i.values.inject(&:+)}.inject(&:+).to_i / 
        capacities_hash.try(:values).to_a.map{|i| i.values.size}.inject(&:+).to_i
    end
  end

  def achievability_poles_size source_target_pairs
    array_of_sizes = []

    timers.each_with_index do |capacity, time|
      array_of_sizes << (achievability_poles_size_at source_target_pairs, time)
    end

    array_of_sizes
  end

  def achievability_poles_size_at source_target_pairs, time
    counter = 0

    source_target_pairs.each do |pair|
      counter += 1 if ((max_flow (pair.first - 1), (pair.last - 1), time) > 0)
    end

    counter
  end

  def achievability_poles source_target_pairs
    array_of_sizes = []

    timers.each_with_index do |capacity, time|
      array_of_sizes << (achievability_poles_at source_target_pairs, time)
    end

    array_of_sizes
  end

  def achievability_poles_at source_target_pairs, time
    counter = []

    source_target_pairs.each do |pair|
      counter << [pair.first, pair.last, ((max_flow (pair.first - 1), (pair.last - 1), time) > 0)]
    end

    counter
  end

  class << self
    def parse_capacities file
      capacities = []

      if (!!(content_from_file, s = Open3.capture2e("octave --eval \"load('#{file}'); netSet\"")).first[/matrix =/] || 
        (File.extname(file) != '.mat' && !!(content_from_file = File.read(file))[/matrix =/]))

        capacities = get_regex_parsed_matrix content_from_file, 'matrix', 'source'
      elsif !!(content_from_file = `h5dump -x #{file}`)[/matrix/]
        doc = Ox.parse content_from_file

        array_to_slice = doc.locate('*/hdf5:DataFromFile')[9].nodes.first.gsub("\n", '').split.map(&:to_i)

        array_to_slice.each_slice((array_to_slice.size**0.5).to_i).to_a.each_with_index do |row, i|
          capacities[i] = []
          
          row.each_with_index do |capacity, j|
            capacities[i][j] = capacity
          end
        end
      else
        puts 'Can not load data from file'
      end

      capacities
    end

    def parse_costs_graph file, capacities, costs_type='1'
      costs_graph_double_hash = {}

      if (!!(content_from_file, s = Open3.capture2e("octave --eval \"load('#{file}'); netSet\"")).
        first[/costs_matrix/] || 
        (File.extname(file) != '.mat' && !!(content_from_file = File.read(file))[/costs_matrix/]))

        costs_graph_matrix = get_regex_parsed_matrix content_from_file, 'costs_matrix', 'source'

        costs_graph_matrix.each_with_index do |i, row|
          row.each_with_index do |j, value|
            if value > 0
              costs_graph_double_hash[i] = {}

              costs_graph_double_hash[i][j] = value
            end
          end
        end
      #elsif !!(content_from_file = `h5dump -x #{file}`)[/matrix/i]
      #  doc = Xo.parse(content_from_file)
      #
      #  doc.locate('*/hdf5:DataFromFile')[0..12][11]
      else
        capacities.each_with_index do |row, i|
          costs_graph_double_hash[i] = {}

          row.each_with_index do |capacity, j|
            if costs_type == '2'
              costs_graph_double_hash[i][j] = 1/capacity.to_f if capacity > 0
            elsif costs_type == '1'
              costs_graph_double_hash[i][j] = 1 if capacity > 0
            end
          end
        end
      end

      costs_graph_double_hash
    end
    
    def parse_requests file, mode='1'
      requests = []

      content_from_file_octave, s = Open3.capture2e("octave --eval \"load('#{file}'); netSet\"")

      content_from_file_raw = File.read(file)
      
      if ((octave = (!!content_from_file_octave[/order/] && !!content_from_file_octave[/lifetime/] &&
        !!content_from_file_octave[/sourceArray/] && !!content_from_file_octave[/targetArray/])) || 
        (File.extname(file) != '.mat' && 
          (raw = ((!!content_from_file_raw[/lifetime/]) && !!content_from_file_raw[/order/] && 
          !!content_from_file_raw[/sourceArray/] && !!content_from_file_raw[/targetArray/]))))

        content = octave ? content_from_file_octave : content_from_file_raw

        source_target_pairs = []

        sources = get_nodes_array content, 'sourceArray', 'targetArray'
  
        targets = get_nodes_array content, 'targetArray', 'order'

        sources.each_with_index { |source, index| source_target_pairs << [source, targets[index]] }

        lifetimes_array = get_nodes_array content, 'lifetime', 'id'

        orders_array = get_nodes_array content, 'order', 'lifetime'

        orders_array.each_with_index do |soure_target_index, index|
          requests << { :size => 1, :start_time => index, :lifetime => lifetimes_array[index], 
            :source => source_target_pairs[soure_target_index - 1].first - 1,
            :target => source_target_pairs[soure_target_index - 1].last - 1, 
            :path => ''
          }
        end
      elsif !!(content_from_file = `h5dump -x #{file}`)[/matrix/]
        doc = Ox.parse content_from_file
        
        source_target_pairs = []

        sources = doc.locate('*/hdf5:DataFromFile')[15].nodes.first.split.map(&:to_i)
  
        targets = doc.locate('*/hdf5:DataFromFile')[17].nodes.first.split.map(&:to_i)

        sources.each_with_index { |source, index| source_target_pairs << [source, targets[index]] }

        lifetimes_array = doc.locate('*/hdf5:DataFromFile')[7].nodes.first.split.map(&:to_i)

        orders_array = doc.locate('*/hdf5:DataFromFile')[11].nodes.first.split.map(&:to_i)

        orders_array.each_with_index do |soure_target_index, index|
          requests << { :size => 1, :start_time => index, :lifetime => lifetimes_array[index], 
            :source => source_target_pairs[soure_target_index - 1].first - 1,
            :target => source_target_pairs[soure_target_index - 1].last - 1, 
            :path => ''
          }
        end
      else
        puts 'Can not load data from file'
      end

      if mode == '2'
        requests = []

        300.times.each do |time|
          source_target_pairs.each do |pair|
            request_count = 10*100/((2*Math::PI)**0.5 * 1)*Math.exp(-(time-150)**2/(2*1**2))

            request_count = request_count.to_i + 3

            requests << { :size => 1, :start_time => time, :lifetime => 20, 
              :source => pair.first - 1,
              :target => pair.last - 1, 
              :path => ''
            }
          end
        end
      end

      [source_target_pairs, requests]
    end

    private
    def get_regex_parsed_matrix content_from_file, word_to_start, word_to_end
      parsed_matrix = []

      matrix = content_from_file[/#{word_to_start}.*?#{word_to_end}/m]

      matrix = matrix.split("\n")

      # There is some useful info after parsing, so we'll remove it
      2.times { matrix.shift }

      2.times { matrix.pop }

      matrix.each_with_index do |value, key|
        parsed_matrix[key] = []

        value.split.each_with_index do |capacity, index|
          parsed_matrix[key][index] = capacity.to_i
        end
      end
      
      parsed_matrix
    end

    def get_nodes_array string, word_to_start, word_to_end
      array = string[/#{word_to_start} =.*?#{word_to_end}/m] 

      array = array.split("\n")

      # There is some useful info after parsing, so we'll remove it
      2.times { array.shift }

      2.times { array.pop }
     
      array.map(&:to_i)
    end
  end
end

options = Slop.new(:help => true) do
  banner 'Usage: foo.rb [options]'

  on :o, :output=, 'Path to output file', :required => true

  on :s, :source=, 'Path to data source file', :required => true

  on :g, :graphs_folder=, 'Folder to write graphs', :required => false

  on :c, :mode_cost=, 'Mode of costs computation', :required => false

  on :m, :mode_distribution=, 'Mode of requests distribution', :required => false

  on :d, :demonize, 'Demonize process', :required => false
end

begin
  options.parse(ARGV)
rescue Slop::Error => e
  unless options[:help]
    $stderr.puts e.message 
    
    $stderr.puts options.help
  end
    
  exit
end

if options[:d]
  Daemons.daemonize
end

modelling_time_start = Time.now

capacities = ProjectEngine.parse_capacities options[:source]

costs_graph = ProjectEngine.parse_costs_graph options[:source], capacities, options[:mode_cost]

source_target_pairs, requests = ProjectEngine.parse_requests options[:source], options[:mode_distribution]

modelling_time = (Time.now - modelling_time_start)

obj = ProjectEngine.new capacities, costs_graph, requests

calculation_time_start = Time.now

requests = obj.start

calculation_time = Time.now - calculation_time_start

if options[:g]
  full_time = obj.summary_capacities_vector.size

  g = Gruff::Line.new

  g.title = "Суммарная пропускная способность" 

  g.labels = Hash.new.tap { |hash| full_time.times { |time| hash[time]=time.to_s if time % 100 == 0 } }

  g.y_axis_label = "Суммарная пропускная способность"

  g.x_axis_label = "Время"

  g.data("1", obj.summary_capacities_vector)

  g.theme = {
    :colors => 'black', # 3077a9 blue, aedaa9 light green
    :marker_color => '#dddddd',
    :font_color => 'black',      
    :background_colors => "white"
    # :background_image => File.expand_path(File.dirname(__FILE__) + "/../assets/backgrounds/43things.png")
  }

  g.write("#{options[:g]}/summary_capacities_vector.png")

  ###################
  g = Gruff::Line.new

  g.title = "Min capacities vector" 

  g.data("1", obj.min_capacity_vector)

  g.labels = Hash.new.tap { |hash| full_time.times { |time| hash[time]=time.to_s if time % 5000 == 0 } }

  g.write("#{options[:g]}/min_capacities_vector.png")

  ###################
  g = Gruff::Line.new

  g.title = "Max capacities vector" 

  g.data("1", obj.max_capacity_vector)

  g.labels = Hash.new.tap { |hash| full_time.times { |time| hash[time]=time.to_s if time % 5000 == 0 } }

  g.write("#{options[:g]}/max_capacities_vector.png")
  
  ###################
  g = Gruff::Line.new

  g.title = "Avg capacities vector" 

  g.data("1", obj.avg_capacity_vector)

  g.labels = Hash.new.tap { |hash| full_time.times { |time| hash[time]=time.to_s if time % 5000 == 0 } }

  g.write("#{options[:g]}/avg_capacities_vector.png")

  ###################
  g = Gruff::Line.new

  g.title = "Number of achievability poles" 

  g.data("1", (obj.achievability_poles_size source_target_pairs))

  g.labels = Hash.new.tap { |hash| full_time.times { |time| hash[time]=time.to_s if time % 5000 == 0 } }

  g.write("#{options[:g]}/number_of_achievability_poles.png")
end

File.open("#{options[:output]}/text_result", 'w+') do |file|
  file.write("All request count: #{requests.size}\n")
  file.write("Success requests count: #{requests.select{ |r| r[:success] == true }.size}\n")
  file.write("Failed requests count: #{requests.select{ |r| r[:success] == false }.size}\n")
  file.write("Modelling time: #{modelling_time}\n")
  file.write("Calculation time #{calculation_time}\n")
  file.write("Last success request number: #{requests.index(requests.select{ |r| r[:success] == true }.last) + 1}\n")
  #file.write("Min capacity vector: #{obj.min_capacity_vector}\n")
  #file.write("Max capacity vector: #{obj.max_capacity_vector}\n")
  #file.write("Avg capacity vector: #{obj.avg_capacity_vector}\n")
  #file.write("Summary vector capacities: #{obj.summary_capacities_vector}\n")
  #file.write("Number of achievability poles: #{obj.achievability_poles_size source_target_pairs}\n")
  #p "Achievability poles: #{obj.achievability_poles source_target_pairs}")
  #file.write("Requests achievability poles: #{requests.map { |i| [i[:source] + 1, i[:target] + 1, i[:success]] }}\n")
  #file.write("Requests path: #{requests.
  #  map { |i| [i[:source] + 1, i[:target]+1, i[:path].
  #    gsub('[', '').gsub(']', '').split(',').map(&:to_i).map{|j|j+1}] }}\n")
end
