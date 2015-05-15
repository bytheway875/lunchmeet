require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require 'sinatra/activerecord'
require 'yaml'
require './models/user.rb'
require './parse_text'
register Sinatra::ActiveRecordExtension
enable 'sessions'

@DB_CONFIG = YAML::load(File.open('config/database.yml'))


# set :database, "mysql://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}"
# set :database, "{adapter: mysql2, host: #{DB_CONFIG['host']}, port: #{DB_CONFIG['port']}, database: #{DB_CONFIG['database']}, username: #{DB_CONFIG['username']}, password: #{DB_CONFIG['password']} }"

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
  sms_count = session['counter'] ||= 1
  twiml = Twilio::TwiML::Response.new do |r|
    response = ParseText.new(params[:Body]).response
    r.Message response + " This is message #{sms_count}"
  end
  session['counter'] += 1
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
