require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require './parse_text'
require 'haml'
require 'sinatra/activerecord'
require './config/environments'
require './models/user'


enable :sessions

get '/' do
  'Hello World! Currently running version ' + Twilio::VERSION + \
  ' of the twilio-ruby library.'
  haml :home
end

get '/sign_up' do
  haml :sign_up
end

post '/sign_up' do
  user = User.new(params)
  user.save
end

get '/receive_messages' do
  sms_count = session['counter'] ||= 1

  body = params[:Body]

  if sms_count == 1
    response = ParseText.new(body).response
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message response[:message]
    end
    if response[:valid]
      session['counter'] += 1
      session['date'] = response[:date]
      session['event'] = response[:event]
    end
  elsif sms_count == 2
    if body.downcase == 'yes'
      twiml = Twilio::TwiML::Response.new do |r|
        r.Message "okay, we'll find someone to hang out with you for #{session['event']} on #{session['date']}."
      end
    session['counter'] += 1
    else
      twiml = Twilio::TwiML::Response.new do |r|
        r.Message "okay, then tell me what you want to do."
      end
      session['counter'] = 1
    end
  elsif sms_count > 2
    session['counter'] = 1
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message "we're resetting your session. something messed up."
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