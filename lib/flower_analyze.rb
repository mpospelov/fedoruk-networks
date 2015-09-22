require 'ruby-fann'
require 'csv'

class FlowerAnalyze
  def initialize(training_data_csv)
    data = CSV.new(training_data_csv).to_a
    inputs = data.map{|el| el[0..3].map(&:to_f) }
    outputs = data.map{|el| [el[-1].to_i] }
    train = RubyFann::TrainData.new(
      inputs: inputs,
      desired_outputs: outputs
    )
    @fann = RubyFann::Standard.new(
      num_inputs: 4,
      hidden_neurons: [3],
      num_outputs: 1
    )
    @fann.set_activation_function_hidden(:sigmoid)
    @fann.set_activation_function_output(:linear)
    @fann.set_train_stop_function(:mse)

    @fann.train_on_data(train, 10000, 10, 0.1)
  end

  def run(input)
    result = @fann.run(input)[0]
    puts result
    (result).round
  end

end
