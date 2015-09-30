class Connection
  
  attr_reader :right_neuron, :left_neuron
  attr_accessor :weight_change, :weight_update_value, :weight

  def initialize(left_neuron, right_neuron)
    @left_neuron = left_neuron
    @right_neuron = right_neuron
    @weight = rand(-0.5..0.5)
    @weight_change = 0.0
    @weight_update_value = 0.1
  end

end