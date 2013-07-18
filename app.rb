require 'rubygems'
require 'sinatra'
require 'fbgraph'


get '/' do
  page = params[:p] || 'check'
  erb :"#{page}"
end

post '/' do
@auth = FBGraph::Canvas.parse_signed_request(APP_CODE, params[:signed_request])
if @auth['page']['liked'] == true
    liked = true
    erb liked
  else
    liked = false
    erb :check
  end
end

get '/vote' do
"this a vote page"
end

get '/vote:id' do

end

get '/thanks/' do
"this is the thank you page"
end

get '/official-rules' do
  erb :official_rules
end

get '/privacy-policy' do
  erb :privacy_policy
end

