require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require 'sinatra/activerecord'
require 'yaml'
require './models/user.rb'

@DB_CONFIG = YAML::load(File.open('config/database.yml'))


 #set :database, "mysql://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}"
#set :database, "{adapter: mysql2, host: #{DB_CONFIG['host']}, port: #{DB_CONFIG['port']}, database: #{DB_CONFIG['database']}, username: #{DB_CONFIG['username']}, password: #{DB_CONFIG['password']} }" 

ActiveRecord::Base.establish_connection(
  adapter: "#{@DB_CONFIG['adapter']}", 
  host: "#{@DB_CONFIG['host']}",
  database: "#{@DB_CONFIG['database']}",
  username: "#{@DB_CONFIG['username']}",
  password: "#{@DB_CONFIG['password']}")


get '/' do
    'Hello World! Currently running version ' + Twilio::VERSION + \
    ' of the twilio-ruby library.'

    #@users = Users.all
    #erb :index
end

get 'receive_messages' do
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message "Hey Monkey. Thanks for the message!"
  end
  twiml.text
end

get '/test_message' do
  account_sid = ENV['TWILIO_SID']
  auth_token = ENV['TWILIO_AUTH']
  client = Twilio::REST::Client.new(account_sid, auth_token)

  from = "+18327421825"

  friends = {
      "+18324658840" => "Shannon",
      "+15205088375" => "Lakeida"
  }
  friends.each do |key, value|
    puts "key"
    puts "value"
    client.account.messages.create(
        :from => from,
        :to => key,
        :body => "Hey #{value}, Monkey party at 6PM. Bring Bananas!"
    )
  end

  "Texts sent"

end
