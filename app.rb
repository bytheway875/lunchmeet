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
  user = User.create(params)

  account_sid = ENV['TWILIO_SID']
  auth_token = ENV['TWILIO_AUTH']
  client = Twilio::REST::Client.new(account_sid, auth_token)

  client.account.messages.create(
    :from => "+18327421825",
    :to => user.cell_phone,
    :body => "Hey #{user.first_name}, Welcome to LunchMeet. Your verification code is #{user.verification_code}."
  )
  redirect "/verify?user=#{user.id}"
end

get '/verify' do
  @user = User.find(params[:user])
  haml :verify
end

post '/verify' do
  @user = User.find(params[:user_id])
  if @user.verification_code == params[:verification_code]
    @user.update(verification_code: true)
    redirect "/start_texting"
  else
    redirect back
  end
end

get "/start_texting" do
  "You're verified!! You can start texting +1-832-742-1825 to start planning lunch and happy hours with coworkers."
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
      event = Event.new(date: session['date'], event: session['event'])
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