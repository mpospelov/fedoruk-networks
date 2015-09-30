require 'ruby-fann'
require 'csv'

DEAD_STATE = {
  0 => [1,0],
  1 => [0,1],
}

class TitanicAnalyze
  def initialize(training_data_csv)
    data = CSV.new(
      training_data_csv,
      headers: true,
      converters: [:all, :blank_to_nil]
    ).to_a.map{|r| r.to_hash}
    inputs = data.map{|el| hash_to_input(el) }
    
    @max0, @min0 = inputs.max_by{|i| i[0]}[0], inputs.min_by{|i| i[0]}[0]
    @max1, @min1 = inputs.max_by{|i| i[1]}[1], inputs.min_by{|i| i[1]}[1]
    @max2, @min2 = inputs.max_by{|i| i[2]}[2], inputs.min_by{|i| i[2]}[2]
    outputs = data.map{|el| DEAD_STATE[el["output"].to_i] }
    @network = NeuralNet.new([3, 2, 2])

    @network.train(
      inputs,
      outputs
    )
  end

  def run(el)
    input = hash_to_input(el)
    result = @network.run(input)
    puts result.to_s
    result.index result.max
  end

  private

  def hash_to_input(hash)
    [
      hash["cabin"].to_f,
      hash["age"].to_f,
      hash["sex"].to_f
    ]
  end

end
