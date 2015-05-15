require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require './parse_text'

enable :sessions

get '/' do
  'Hello World! Currently running version ' + Twilio::VERSION + \
  ' of the twilio-ruby library.'
end

get '/receive_messages' do
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
    client.account.messages.create(
        :from => from,
        :to => key,
        :body => "Hey #{value}, Monkey party at 6PM. Bring Bananas!"
    )
  end

  "Texts sent"

end