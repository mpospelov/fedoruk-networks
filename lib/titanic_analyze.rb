require 'ruby-fann'
require 'csv'

class TitanicAnalyze
  def initialize(training_data_csv)
    data =CSV.new(
      training_data_csv,
      headers: true,
      converters: [:all, :blank_to_nil]
    ).to_a.map{|r| r.to_hash}
    inputs = data.map{|el| hash_to_input(el) }
    outputs = data.map{|el| [el["output"]] }
    debugger
    train = RubyFann::TrainData.new(
      inputs: inputs,
      desired_outputs: outputs
    )
    @fann = RubyFann::Standard.new(
      num_inputs: 3,
      hidden_neurons: [3],
      num_outputs: 1
    )
    @fann.train_on_data(train, 1000, 10, 0.1)
  end

  def run(el)
    @fann.run(hash_to_input(el))[0].round
  end

  private

  def hash_to_input(hash)
    [
      hash["cabin"].to_f / 3,
      hash["age"].to_f / 2,
      hash["sex"].to_f / 2
    ]
  end

end
