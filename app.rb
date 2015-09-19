require 'sinatra'
configure { set :server, :puma }


post '/mpospelov' do
  "Hello World!"
end

post '/akultisheva' do
  "Hello Nastya"
end
