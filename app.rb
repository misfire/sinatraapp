require 'rubygems'
require 'sinatra'
require "data_mapper"


# database connection from heroku
DataMapper.setup(:default, ENV["DATABASE_URL"])

class Group
  
  include DataMapper::Resource
  
  property  :id,            Serial
  property  :name,          String, :required => true
  property  :is_active,     Boolean, :required => true
  property  :promo_code,    String, :required => true
  property  :created_at,    DateTime,  :required => false
  property  :updated_at,    DateTime,  :required => false
    
end

# Create or upgrade the database all at once
DataMapper.auto_upgrade!
>>>>>>> 7c543dd8b4f2f94dccc654a99e21b5bc63f00e66


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

