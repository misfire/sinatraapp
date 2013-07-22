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

  has n, :products, :constraint => :destroy
  has n, :promotions, :constraint => :destroy
    
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
  property  :email,         String, :required => false
  property  :ip_address,    String
  property  :subscribed,    Boolean
  property  :username,      String
  property  :created_at,    DateTime 

  belongs_to :product

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
  @groups = Group.all(:order => [:id.asc])
  erb :"admin/#{page}"
end

get '/admin/day/new' do
  page = params[:p] || 'new'
  @title = "Create new Day"
  erb :"admin/day/#{page}"
end

post '/admin/day/create' do
  @day = Group.new(params[:day])
  if @day.save
    redirect "/admin/day/show/#{@day.id}"
  else
    redirect "/admin"
  end
end

get '/admin/day/show/:id' do
  page = params[:p] || 'show'
  @day = Group.get(params[:id])
  if @day
  erb :"admin/day/#{page}"
  else
    redirect('/admin')
  end
end

get '/admin/day/delete/:id' do
  day = Group.get(params[:id])
  unless day.nil?
    day.destroy
  end
  redirect('/admin')
end

get '/admin/day/edit/:id' do
  page = params[:p] || 'edit'
  @day = Group.get(params[:id])
  if @day
    erb :"admin/day/#{page}"
  else
    redirect('/admin')
  end  
end

post '/admin/day/update' do
  @day = Group.get(params[:id])
  if @day.update(params[:day])
    redirect "/admin/day/show/#{@day.id}"
  else 
    redirect('/admin')
  end  
end


get '/admin/day/products/new/:dayid' do
  page = params[:p] || 'new'
  @day = Group.get(params[:dayid])
  @title = "Create new product"
  erb :"admin/products/#{page}"
end

post '/admin/day/products/create/:dayid' do
  day = Group.get(params[:dayid])
  @product = day.products.new(params[:product])
  if @product.save
    redirect "/admin/day/show/#{day.id}"
  else
    redirect "/admin"
  end
end

get '/admin/day/products/show/:dayid/:id' do
  page = params[:p] || 'show'
  @day = Group.get(params[:dayid])
  @product = @day.products.get(params[:id])
  if @product
  erb :"admin/products/#{page}"
  else
    redirect('/admin')
  end
end

get '/admin/day/products/edit/:dayid/:id' do
  page = params[:p] || 'edit'
  @day = Group.get(params[:dayid])
  @product = @day.products.get(params[:id])
  if @product
  erb :"admin/products/#{page}"
  else
    redirect('/admin')
  end
end

post '/admin/day/products/update' do
  @day = Group.get(params[:dayid])
  @product = @day.products.get(params[:id])
  if @product.update(params[:product])
    redirect "/admin/day/products/show/#{@day.id}/#{@product.id}"
  else 
    redirect('/admin')
  end  
end

get '/admin/day/products/delete/:dayid/:id' do
  page = :dayid
  day = Group.get(params[:dayid])
  product = day.products.get(params[:id])
  unless product.nil?
    product.destroy
  end
  redirect "/admin/day/show/#{day.id}"
end

get '/admin/day/products/vote/:dayid/:id' do
  day = Group.get(params[:dayid])
  @product = day.products.get(params[:id])
  @vote = @product.votes.new(:email => 'aznlucidx@gmail.com', :ip_address => '192.168.0.1', :subscribed => 'true', :username => 'misfire')
  if @vote.save
    redirect "/admin/day/show/#{day.id}"
  else
    redirect "/admin"
  end
end

get '/admin/day/promotions/show/:dayid/:id' do
  page = params[:p] || 'show'
  @day = Group.get(params[:dayid])
  @promotion = @day.promotions.get(params[:id])
  if @promotion
  erb :"admin/products/#{page}"
  else
    redirect('/admin')
  end
end

get '/admin/day/promotions/new/:dayid' do
  page = params[:p] || 'new'
  @day = Group.get(params[:dayid])
  @title = "Create new promotion"
  erb :"admin/promotions/#{page}"
end

post '/admin/day/promotions/create/:dayid' do
  day = Group.get(params[:dayid])
  @promotion = day.promotions.new(params[:promotion])
  if @promotion.save
    redirect "/admin/day/show/#{day.id}"
  else
    redirect "/admin"
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

