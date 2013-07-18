require 'rubygems'
require 'sinatra'
require "data_mapper"

set :raise_errors, true
set :show_exceptions, true


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

  has n, :products
  has n, :promotions
    
end

class Product

  include DataMapper::Resource

  property  :id,            Serial
  property  :productname,   String, :required => true
  property  :description,   String, :required => true
  property  :picture,       String, :required => true
  property  :created_at,    DateTime,  :required => false
  property  :updated_at,    DateTime,  :required => false

  belongs_to :group
  has n, :votes

end

class Promotion

  include DataMapper::Resource

  property  :id,            Serial
  property  :productname,   String, :required => true
  property  :description,   String, :required => true
  property  :picture,       String, :required => true
  property  :created_at,    DateTime,  :required => false
  property  :updated_at,    DateTime,  :required => false

  belongs_to :group

end

class Vote

  include DataMapper::Resource

  property  :id,            Serial
  property  :email,         String, required => false
  property  :ip_address,    String
  property  :subscribed,    Boolean
  property  :username,      String
  property  :created_at,    DateTime 

  belongs_to :product

end


# Create or upgrade the database all at once
DataMapper.auto_migrate!


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
  @groups = Group.all(:order => [:name.asc])
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
    redirect "/admin/show/#{@day.id}"
  else
    redirect "/admin"
  end
end

get '/admin/show/:id' do
  page = params[:p] || 'show'
  @day = Group.get(params[:id])
  if @day
  erb :"admin/#{page}"
  else
    redirect('/admin')
  end
end

get '/admin/delete/:id' do
  day = Group.get(params[:id])
  unless day.nil?
    day.destroy
  end
  redirect('/admin')
end

get '/admin/edit/:id' do
  page = params[:p] || 'edit'
  @day = Group.get(params[:id])
  if @day
    erb :"admin/#{page}"
  else
    redirect('/admin')
  end  
end

post '/admin/update' do
  @day = Group.get(params[:id])
  if @day.update(params[:day])
    redirect "/admin/show/#{@day.id}"
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

