require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

get '/' do
  'Hello World! Currently running version ' + Twilio::VERSION + \
  ' of the twilio-ruby library.'
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