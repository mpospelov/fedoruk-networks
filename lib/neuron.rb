class Neuron
  ZERO_TOLERANCE = Math.exp(-16)
  MIN_STEP, MAX_STEP = Math.exp(-6), 50
  A, B = 1.2, 5

  attr_reader :leaving, :incomming, :delta
  attr_accessor :last_output, :gradient, :prev_gradient

  def initialize 
    @incomming = []
    @leaving = []
    @last_output = 0.0
    @delta = 0.0
    @gradient = 0.0
    @prev_gradient = 0.0
  end

  def update_delta_and_gradient(training_error)
    neuron_error = if output_neuron?
      -training_error
    else
      @leaving.map do |connection|
        connection.right_neuron.delta * connection.weight
      end.reduce(:+)
    end
    activation_derivative = @last_output * (1.0 - @last_output)
    @delta = neuron_error * activation_derivative
    # @prev_gradient = @gradient
    # @gradient = @gradient + @last_output * @delta
    @incomming.each do |connection|
      source_neuron = connection.left_neuron 
      source_neuron.prev_gradient = source_neuron.gradient
      source_neuron.gradient += source_neuron.last_output * @delta
      puts "Gradient: #{source_neuron.gradient}, #{source_neuron.prev_gradient}"
    end
  end

  def update_weights
    @incomming.each do |connection|
      source_neuron = connection.left_neuron
      weight_change = connection.weight_change
      weight_update_value = connection.weight_update_value
      c = sign(source_neuron.gradient * source_neuron.prev_gradient)
      puts "Sing: #{c}" 
      # puts "Gradient: #{source_neuron.gradient}, #{source_neuron.prev_gradient}"
      case c
        when 1 then
          weight_update_value = [
            weight_update_value * A, 
            MAX_STEP
          ].min
          weight_change = -sign(source_neuron.gradient) * weight_update_value
        when -1 then
          weight_update_value = [
            weight_update_value * B, 
            MIN_STEP
          ].max
          weight_change = -weight_change 
          source_neuron.prev_gradient = source_neuron.gradient
          source_neuron.gradient = 0.0
        when 0 then
          weight_change = -sign(source_neuron.gradient) * connection.weight_update_value
      end
      # puts "Change: #{weight_change}"
      # puts "Update value: #{weight_update_value}"

      connection.weight += weight_change
      connection.weight_change = weight_change
      connection.weight_update_value = weight_update_value
    end
  end

  def sign(x)

    if x > ZERO_TOLERANCE
      1
    elsif x < -ZERO_TOLERANCE
      -1
    else
      0 # x is zero, or a float very close to zero
    end

  end
  
  def init_connections(next_layer)
    next_layer.neurons.each do |next_layer_neuron|
      connection = Connection.new(self, next_layer_neuron)
      @leaving.push(connection)
      next_layer_neuron.incomming.push(connection)
    end
  end

  def sigmoid(x)
    1.0 / (1.0 + Math.exp(-x))
  end

  def input_neuron?
    @incomming.empty?
  end

  def output_neuron?
    @leaving.empty?
  end

  def run(input)
    sum = 0
    @incomming.map.with_index do |connection, i|
      weight = connection.weight
      sum += input[i] * weight
    end
    @last_output = sigmoid(sum)
  end  

  def to_hash       
    {
      incommig_connection_count: @incomming.count,
      leaving_connection_count: @leaving.count, 
      incoming_connection_weights: @incomming.map(&:weight)
    }
  end

end
