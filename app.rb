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


get '/' do
  page = params[:p] || 'check'
  erb :"#{page}"
end

post '/' do
#@auth = FBGraph::Canvas.parse_signed_request(APP_CODE, params[:signed_request])
#if @auth['page']['liked'] == true
#    liked = true
#    erb liked
#  else
#    liked = false
#    erb :check
#  end
end

get '/admin' do
  page = params[:p] || 'index'
  @title = "List Days"
  @groups = Group.all(:order => [:id.asc])
  erb :"admin/#{page}"
end

get '/admin/new' do
  page = params[:p] || 'new'
  @title = "Create new Day"
  erb :"admin/#{page}"
end

post '/admin/create' do
  @day = Group.new(params[:day])
  if @day.save
    redirect "/admin/"
  else
    redirect "/admin/"
  end
end

get '/show/:id' do
  page = params[:p] || 'show'
  @day = Groups.get(params[:id])
  if @day
  erb :"admin/#{page}"
  else
    redirect('/admin')
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

