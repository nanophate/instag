require 'sinatra'
require 'instagram'

enable :sessions
CALLBACK_URL = 'http://instag.herokuapp.com/oauth/callback'

Instagram.configure do |config|
 config.client_id = ENV['client_id']
 config.client_secret = ENV['client_secret']
end

get '/' do
 erb :landingpage
end

get '/oauth/connect' do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get '/oauth/callback' do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect '/feed'
end

get "/feed" do
  client = Instagram.client(:access_token => session[:access_token])
  @user = client.user.username
  @recent = client.user_recent_media
  erb :index
end



