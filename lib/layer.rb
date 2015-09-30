class Layer
  attr_reader :neurons
  def initialize(network, neurons_count)
    @network = network
    @neurons = []
    neurons_count.times do
      @neurons.push(Neuron.new)
    end
  end

  def connect(next_layer)
    @neurons.each do |neuron|
      neuron.init_connections(next_layer)
    end
  end

  def input_layer?
    @network.layers[0] == self
  end

  def run(input)
    if input_layer?
      input.map.with_index do |val, i|
        @neurons[i].last_output = val
      end
    else
      @neurons.map do |neuron|
        neuron.run(input)
      end
    end
  end

  def run_on_prev_layer_outputs(layer)
    input = layer.neurons.map(&:last_output)
    run(input)
  end

  def to_hash
    {
      neurons_count: @neurons.count,
      neurons: @neurons.map(&:to_hash)
    }
  end

end