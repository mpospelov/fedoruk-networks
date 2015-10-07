require 'json'
require './lib/flower_analyze'
require 'pp'

AKULTYSHEVA_NETWORK = FlowerAnalyze.new(File.open('train_data/kultysheva.csv').read)

training_data_csv = File.open('test_data/kultysheva.csv').read
data = CSV.new(training_data_csv).to_a
result = []
data.each do |input|
  input.map!(&:to_f)
  result << {
    "param1" => input[0],
    "param2" => input[1],
    "param3" => input[2],
    "param4" => input[3],
    "output" => input[4],
    "network_output" => AKULTYSHEVA_NETWORK.run(input[0..3])
  }
end
result << { same: result.select{|el| el["output"] == el["network_output"] }.count, total: result.count }
pp result
