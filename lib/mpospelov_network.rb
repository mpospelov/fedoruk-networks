require 'json'
require 'ruby-fann'
require 'byebug'
require 'gruff'
require 'ruby_fann/neurotica'


class TweetAnalyze
  MAX_EPOCH ||= 1000
  DESIRED_MSE ||= 0.01

  INPUTS_SIZE ||= 144

  @@mse_train_errors = []
  @@mse_test_errors = []

  attr_accessor :json_test_data, :json_train_data, :minserror_train, :minserror_test,
                :network, :train_data, :network, :hidden_multiplier

  def initialize(train_file: nil, test_file: nil)
    @json_test_data = JSONNetworkData.new(test_file)
    @json_train_data = JSONNetworkData.new(train_file)
    @minserror_train = @minserror_test = 0
    @hidden_multiplier = 2
    build_neuron_network
  end

  def self.draw_plot
    g = Gruff::Line.new
    g.title = 'Gruff Example'
    g.data "Train data MSE", @@mse_train_errors
    g.data "Test data MSE", @@mse_test_errors
    g
  end

  def self.draw_neurotica_plot
    paint = RubyFann::Neurotica.new
    paint.graph(@network, "tmp/plot.png")
    File.open("tmp/plot.png")
  end

  def build_neuron_network
    @network = RubyFann::Standard.new num_inputs: INPUTS_SIZE,
                                      hidden_neurons:
                                        [INPUTS_SIZE * @hidden_multiplier, INPUTS_SIZE * @hidden_multiplier * 0.5],
                                      num_outputs: 1

    network.set_activation_function_hidden(:sigmoid_symmetric)
    network.set_activation_function_output(:sigmoid_symmetric)
    network.set_train_stop_function(:mse)
  end

  def run
    @json_test_data.inputs.each_with_index do |test_input, index|
      tweet = @json_test_data.get_tweet(index)
      result = network.run(test_input)
      error = (result.first - tweet[:value]["weight"])**2
      @minserror_test += error
    end

    @minserror_test = @minserror_test / (2 * @json_test_data.inputs.count)
    puts "Error: #{@minserror_test}"
    @@mse_test_errors << @minserror_test
  end

  def run_on_train_data
    @json_train_data.inputs.each_with_index do |train_input, index|
      tweet = @json_train_data.get_tweet(index)
      result = network.run(train_input)
      error = (result.first - tweet[:value]["weight"])**2
      @minserror_train += error
    end

    @minserror_train = @minserror_train / (2 * @json_train_data.inputs.count)
    puts "Train Error: #{@minserror_train}"
    @@mse_train_errors << @minserror_train
  end

  def train
    network.train_on_data(@json_train_data.build_train_data, MAX_EPOCH, 10, DESIRED_MSE)
  end

  def self.run_network
    train_data_files = Dir["calculate_error/[0-9]*_collection*"]
    train_data_files.each do |train_file|
      analyze_with_network = TweetAnalyze.new train_file: train_file,
                                              test_file: "calculate_error/test_collection.json"
      analyze_with_network.train
      analyze_with_network.run
      analyze_with_network.run_on_train_data
    end
  end

  def self.run_changing_neurons_network
    2.upto(10).each do |hidden_multiplier|
      analyze_with_network = TweetAnalyze.new train_file: "calculate_error/6000_collection.json",
                                              test_file: "calculate_error/test_collection.json"
      analyze_with_network.hidden_multiplier = hidden_multiplier
      analyze_with_network.train
      analyze_with_network.run
      analyze_with_network.run_on_train_data
    end
  end

  class JSONNetworkData
    attr_accessor :data, :inputs, :outputs, :train_data

    def initialize(file_path)
      @data = JSON.parse File.read(file_path)
    end

    def inputs
      @inputs ||= begin
        result = []
        @data.map do |tweet, data|
          result << data["code"].split("").map(&:to_i)
        end
        result
      end
    end

    def get_tweet(index)
      record = @data.to_a[index]
      attrs = {}
      attrs[:name] = record[0]
      attrs[:value] = record[1]
      attrs
    end

    def outputs
      @outputs ||= begin
        result = []
        @data.map do |tweet, data|
          result << [data["weight"].to_f]
        end
        result
      end
    end

    def build_train_data
      @train_data ||= RubyFann::TrainData.new inputs: inputs, desired_outputs: outputs
    end

  end

end
