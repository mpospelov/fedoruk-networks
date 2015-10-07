require 'ruby-fann'
require 'csv'
require './lib/neural_net.rb'

FLOWERS = {
  0 => [1,0,0],
  1 => [0,1,0],
  2 => [0,0,1]
}

class FlowerAnalyze
  attr_reader :network
  def initialize(training_data_csv)
    @network = NeuralNet.new([4,4,3])
    data = CSV.new(training_data_csv).to_a
    inputs = data.map{|el| el[0..3].map(&:to_f) }
    inputs.max_by{|e|}
    @max0, @min0 = inputs.max_by{|i| i[0]}[0], inputs.min_by{|i| i[0]}[0]
    @max1, @min1 = inputs.max_by{|i| i[1]}[1], inputs.min_by{|i| i[1]}[1]
    @max2, @min2 = inputs.max_by{|i| i[2]}[2], inputs.min_by{|i| i[2]}[2]
    @max3, @min3 = inputs.max_by{|i| i[3]}[3], inputs.min_by{|i| i[3]}[3]
    inputs.each_with_index do |input, i|
      inputs[i] = [
        normalize(input[0], @max0, @min0),
        normalize(input[1], @max1, @min1),
        normalize(input[2], @max2, @min2),
        normalize(input[3], @max3, @min3)
      ]
    end
    outputs = data.map{|el| FLOWERS[el[4].to_i] }

    @network.train(
      inputs,
      outputs,
      error_threshold: 0.01,
      max_iterations: 1_000,
      log_every: 100
    )
  end

  def run(input)
    normalized_input = [
      normalize(input[0], @max0, @min0),
      normalize(input[1], @max1, @min1),
      normalize(input[2], @max2, @min2),
      normalize(input[3], @max3, @min3)
    ]
    result = @network.run(normalized_input)
    puts result.to_s
    result.index result.max
  end

  def normalize(val, high, low)
    (val - low) / (high - low)
  end
end
