require 'rubygems'
require 'twilio-ruby'
require 'sinatra'

get '/' do
    'Hello World! Currently running version ' + Twilio::VERSION + \
    ' of the twilio-ruby library.'
end

get '/send_message' do
    account_sid = "AC58c149db53a8075bb3785f448ae3876d"
    auth_token = "3f0abae5327dc6cca36a56abb33b82a5"
    client = Twilio::REST::Client.new account_sid, auth_token
    
    from = "+18327421825" # Your Twilio number
    
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
                                       puts "Sent message to #{value}"
    end
end
