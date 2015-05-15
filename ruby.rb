require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require './parse_text'

enable :sessions

get '/' do
  'Hello World! Currently running version ' + Twilio::VERSION + \
  ' of the twilio-ruby library.'
end

get 'receive_messages' do
  body = params[:Body]

  sms_count = session['counter'] ||= 1
  if sms_count == 1
    response = ParseText.new(body).response
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message response.message
    end
    if response.valid
      session['counter'] += 1
      session['date'] = response.date
      session['event'] = response.event
    end
  elsif sms_count == 2
    if body.downcase == 'yes'
      twiml = Twilio::TwiML::Response.new do |r|
        r.Message "okay, we'll find someone to hang out with you."
      end
    end
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
    client.account.messages.create(
        :from => from,
        :to => key,
        :body => "Hey #{value}, Monkey party at 6PM. Bring Bananas!"
    )
  end

  "Texts sent"

end