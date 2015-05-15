require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require 'data_mapper'
require 'dm-migrations'
require 'dm-core'
require './models/models.rb'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

enable :sessions


get '/' do
    @twilio_version = Twilio::VERSION

    erb :home
end

get '/users' do
  @title = 'Current Members:'
  @users = User.all
  erb :"users/index"
end

get "/users/new" do
 @title = "Enter your information to join."
 @user = User.new
 erb :"users/new"
end

post "/users" do
 @user = User.new(params[:user])
 if @user.save
   redirect "users/#{@user.id}", :notice => 'Congrats! You are now a member.'
 else
   erb :"users/new", :error => 'Something went wrong. Try again.'
 end
end


get "/users/:id" do
  @user = User.get(params[:id])
  @title = "Member Details"
  erb :"users/show"
end

# edit user
get "/users/:id/edit" do
  @user = User.get(params[:id])
  @title = "Edit Member"
  erb :"users/edit"
end

put "/users/:id" do
  @user = User.get(params[:id])
 if @user.update(params[:user])
  redirect "/users/#{@user.id}" , :notice => 'Updated Successfully.'
  else
    erb :"user/edit", :error => 'Something went wrong.  Try again.'
  end
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