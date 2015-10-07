require 'byebug'
require 'logger'
require './lib/layer.rb'
require './lib/neuron.rb'
require './lib/connection.rb'

NETWORK_LOG = Logger.new('logfile.log')

class NeuralNet
  attr_reader :layers

  def initialize(form)
    @form = form
    @layers = []
    @form.each do |neurons_count|
      @layers.push Layer.new(self, neurons_count)
    end
    @layers.each_with_index do |layer, i|
      next_layer = @layers[i+1]
      layer.connect(next_layer) if next_layer
    end
    @input_layer = layers[0]
    @output_layer = layers[-1]
  end

  def train(inputs: ,outputs:, epoches: 1000, error_threshold: 0.1)
    i = 0
    while i < epoches
      train_error = single_train_error(inputs: inputs, outputs: outputs)
      puts "#{i}. MSE: #{train_error}"
      break if error_threshold && (train_error < error_threshold)
      i+=1
    end
  end

  def single_train_error(inputs, outputs)
    total_mse = 0

    inputs.each_with_index do |input, i|
      result = run(input)
      training_error = calculate_training_error(result, outputs[i])
      update_gradients(training_error)
      total_mse += mean_squared_error(training_error)
    end

    update_weights

    total_mse / inputs.length.to_f # average mean squared error for batch
  end

  def update_weights
    @layers.each do |layer|
      layer.neurons.each do |neuron|
        neuron.update_weights
      end
    end
  end

  def calculate_training_error(outputs, expected_outputs)
    outputs.map.with_index do |output, i|
      output - expected_outputs[i]
    end
  end

  def update_gradients(training_error)
    @layers.reverse.each do |layer|
      layer.neurons.each_with_index do |neuron,i|
        neuron.update_delta_and_gradient(training_error[i])
      end
    end
  end

  def mean_squared_error(errors)
    errors.map{|e| e**2}.reduce(:+) / errors.length.to_f
  end

  def run(input)
    if input.count != @input_layer.neurons.count
      raise "The input size should be #{input_layer.neurons.count}"
    end
    @input_layer.run(input)

    layers.each_with_index do |layer, i|
      next if @input_layer == layer
      layer.run_on_prev_layer_outputs(layers[i-1])
    end
    @output_layer.neurons.map(&:last_output)
  end

  def inspect
    result = [
      "\n#Network",
      "\tlayers_count = #{@layers.count}",
      "\tlayers info:"
    ] << @layers.map{|l| l.to_hash.to_s }.join("\n")
    result.join("\n")
  end

end
