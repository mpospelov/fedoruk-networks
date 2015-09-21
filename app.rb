require 'sinatra'
require 'sinatra/cross_origin'
require 'byebug'
require 'json'
require './lib/titanic_analyze'

MPOSPELOV_NETWORK = TitanicAnalyze.new(File.open('train_data/pospelov.csv').read)
OUTPUTS = {
  0 => "Погиб",
  1 => "Выжил"
}

configure do
  set :server, :puma
  enable :cross_origin
end

post '/mpospelov', provides: :json do
  input = JSON.parse(request.body.read)
  { output: OUTPUTS[MPOSPELOV_NETWORK.run(input)] }.to_json
end

post '/akultisheva' do
  "Hello Nastya"
end

options "*" do
  response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
  200
end
