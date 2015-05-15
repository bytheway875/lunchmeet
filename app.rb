require 'rubygems'
require 'sinatra'
require 'twilio-ruby'
require 'data_mapper'
require 'dm-migrations'
require './models/models.rb'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

enable :sessions


get '/?' do
    
    @title = 'Welcome to LunchMeet'
    @twilio_version = Twilio::VERSION

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
  @user = User.find(params[:id])
  @title = "Member"
  erb :"users/show"
end

# edit user
get "/users/:id/edit" do
  @user = User.find(params[:id])
  @title = "Edit Member"
  erb :"users/edit"
end

put "/users/:id" do
  @user = User.find(params[:id])
  @user.update(params[:user])
  redirect "/users/#{@user.id}"
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
