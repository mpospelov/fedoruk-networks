require 'sinatra'
require 'sinatra/cross_origin'
require 'byebug'
require 'json'
require './lib/titanic_analyze'
require './lib/flower_analyze'
class MyApp < Sinatra::Base

  MPOSPELOV_NETWORK = TitanicAnalyze.new(File.open('train_data/pospelov.csv').read)
  AKULTYSHEVA_NETWORK = FlowerAnalyze.new(File.open('train_data/kultysheva.csv').read)
  OUTPUTS = {
    0 => "Погиб",
    1 => "Выжил"
  }
  KOUTPUTS = {
    0 => {
      number: 0,
      name: "Iris Setosa",
      url: "/images/iris_setosa.jpg"
    },
    1 => {
      number: 1,
      name: "Iris Versicolour",
      url: "/images/iris_versicolor.jpg"
    },
    2 => {
      number: 2,
      name: "Iris Virginica",
      url: "/images/iris_virginica.jpg"
    }
  }

  configure do
    set :server, :puma
    enable :cross_origin
  end

  post '/mpospelov', provides: :json do
    response.headers["Access-Control-Allow-Origin"] = "*"
    input = JSON.parse(request.body.read)
    { output: OUTPUTS[MPOSPELOV_NETWORK.run(input)] }.to_json
  end

  get '/mpospelov_test' do
    training_data_csv = File.open('test_data/pospelov.csv').read
    data = CSV.new(
      training_data_csv,
      headers: true,
      converters: [:all, :blank_to_nil]
    ).to_a.map{|r| r.to_hash}
    result = []
    data.each do |input|
      result << input.merge("network_output" => MPOSPELOV_NETWORK.run(input))
    end
    result << { same: result.select{|el| el["output"] == el["network_output"] }.count, total: result.count }
    result.to_json
  end

  post '/akultisheva' do
    response.headers["Access-Control-Allow-Origin"] = "*"
    input = JSON.parse(request.body.read)
    input.map!(&:to_f)
    { output: KOUTPUTS[AKULTYSHEVA_NETWORK.run(input)] }.to_json
  end

  get '/akultisheva_test' do
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
    result.to_json
  end

  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end
end
