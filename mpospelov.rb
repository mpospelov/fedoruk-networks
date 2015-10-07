require 'json'
require './lib/titanic_analyze'
require 'csv'
require 'pp'

MPOSPELOV_NETWORK = TitanicAnalyze.new(File.open('train_data/pospelov.csv').read)

training_data_csv = File.open('test_data/pospelov.csv').read
data = CSV.new(
  training_data_csv,
  :headers => true,
  :converters => [:all, :blank_to_nil]
).to_a.map{|r| r.to_hash}
result = []
data.each do |input|
  result << input.merge("network_output" => MPOSPELOV_NETWORK.run(input))
end
result << { :same => result.select{|el| el["output"] == el["network_output"] }.count, :total => result.count }
pp result
