require 'rubygems'
require 'sinatra'
require "data_mapper"
require "./lib/authorization"

set :raise_errors, true
set :show_exceptions, true


# database connection from heroku
DataMapper.setup(:default, ENV["DATABASE_URL"])

class Email

  include DataMapper::Resource

  property :id,             Serial
  property :username,       String
  property :email,          String, :required => false
  property :created_at,    DateTime,  :required => false

end

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
  has n, :votes, :constraint => :destroy

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

helpers do
  include Sinatra::Authorization
end


get '/' do
  page = params[:p] || 'index'
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

post '/email/create' do
  @email = Email.new(params[:email])
  if @email.save
    redirect "/vote"
  else
    redirect "/admin"
  end
end

get '/vote' do
  @groups = Group.first(:is_active => true)
  erb :"vote"
end

get '/voted' do 
  erb :"voted"
end

get '/end' do
  erb :"theend"
end

get '/admin' do
  require_admin
  page = params[:p] || 'index'
  @groups = Group.all(:order => [:id.asc])
  @emails = Email.all(:order => [:id.asc])
  erb :"admin/#{page}", :layout => :admin
end

get '/admin/day/new' do
  require_admin
  page = params[:p] || 'new'
  @title = "Create new Day"
  erb :"admin/day/#{page}", :layout => :admin
end

post '/admin/day/create' do
  require_admin
  @day = Group.new(params[:day])
  if @day.save
    redirect "/admin/day/show/#{@day.id}"
  else
    redirect "/admin"
  end
end

get '/admin/day/show/:id' do
  require_admin
  page = params[:p] || 'show'
  @day = Group.get(params[:id])
  if @day
  erb :"admin/day/#{page}", :layout => :admin
  else
    redirect('/admin')
  end
end

get '/admin/day/delete/:id' do
  require_admin
  day = Group.get(params[:id])
  unless day.nil?
    day.destroy
  end
  redirect('/admin')
end

get '/admin/day/edit/:id' do
  require_admin
  page = params[:p] || 'edit'
  @day = Group.get(params[:id])
  if @day
    erb :"admin/day/#{page}", :layout => :admin
  else
    redirect('/admin')
  end  
end

post '/admin/day/update' do
  require_admin
  @day = Group.get(params[:id])
  if @day.update(params[:day])
    redirect "/admin/day/show/#{@day.id}"
  else 
    redirect('/admin')
  end  
end


get '/admin/day/products/new/:dayid' do
  require_admin
  page = params[:p] || 'new'
  @day = Group.get(params[:dayid])
  @title = "Create new product"
  erb :"admin/products/#{page}", :layout => :admin
end

post '/admin/day/products/create/:dayid' do
  require_admin
  day = Group.get(params[:dayid])
  @product = day.products.new(params[:product])
  if @product.save
    redirect "/admin/day/show/#{day.id}"
  else
    redirect "/admin"
  end
end

get '/admin/day/products/show/:dayid/:id' do
  require_admin
  page = params[:p] || 'show'
  @day = Group.get(params[:dayid])
  @product = @day.products.get(params[:id])
  if @product
  erb :"admin/products/#{page}", :layout => :admin
  else
    redirect('/admin')
  end
end

get '/admin/day/products/edit/:dayid/:id' do
  require_admin
  page = params[:p] || 'edit'
  @day = Group.get(params[:dayid])
  @product = @day.products.get(params[:id])
  if @product
  erb :"admin/products/#{page}", :layout => :admin
  else
    redirect('/admin')
  end
end

post '/admin/day/products/update' do
  require_admin
  @day = Group.get(params[:dayid])
  @product = @day.products.get(params[:id])
  if @product.update(params[:product])
    redirect "/admin/day/products/show/#{@day.id}/#{@product.id}"
  else 
    redirect('/admin')
  end  
end

get '/admin/day/products/delete/:dayid/:id' do
  require_admin
  page = :dayid
  day = Group.get(params[:dayid])
  product = day.products.get(params[:id])
  unless product.nil?
    product.destroy
  end
  redirect "/admin/day/show/#{day.id}"
end

get '/admin/day/products/vote/:dayid/:id' do
  require_admin
  day = Group.get(params[:dayid])
  @product = day.products.get(params[:id])
  @vote = @product.votes.new(:email => 'aznlucidx@gmail.com', :ip_address => '192.168.0.1', :subscribed => 'true', :username => 'misfire')
  if @vote.save
    redirect "/admin/day/show/#{day.id}"
  else
    redirect "/admin"
  end
end

post '/vote/:id' do
  day = Group.get(params[:dayid])
  @product = Product.get(params[:id])
  @vote = @product.votes.new(params[:votes])
    if @vote.save
    redirect "/voted"
  else
    redirect "/vote"
  end
end

get '/admin/day/promotions/show/:dayid/:id' do
  require_admin
  page = params[:p] || 'show'
  @day = Group.get(params[:dayid])
  @promotion = @day.promotions.get(params[:id])
  if @promotion
  erb :"admin/promotions/#{page}", :layout => :admin
  else
    redirect('/admin')
  end
end

get '/admin/day/promotions/new/:dayid' do
  require_admin
  page = params[:p] || 'new'
  @day = Group.get(params[:dayid])
  @title = "Create new promotion"
  erb :"admin/promotions/#{page}", :layout => :admin
end

post '/admin/day/promotions/create/:dayid' do
  require_admin
  day = Group.get(params[:dayid])
  @promotion = day.promotions.new(params[:promotion])
  if @promotion.save
    redirect "/admin/day/show/#{day.id}"
  else
    redirect "/admin"
  end
end

get '/admin/day/promotions/edit/:dayid/:id' do
  require_admin
  page = params[:p] || 'edit'
  @day = Group.get(params[:dayid])
  @promotion = @day.promotions.get(params[:id])
  if @promotion
  erb :"admin/promotions/#{page}", :layout => :admin
  else
    redirect('/admin')
  end
end

post '/admin/day/promotions/update' do
  require_admin
  @day = Group.get(params[:dayid])
  @promotion = @day.promotions.get(params[:id])
  if @promotion.update(params[:promotion])
    redirect "/admin/day/promotions/show/#{@day.id}/#{@promotion.id}"
  else 
    redirect('/admin')
  end  
end

get '/admin/day/promotions/delete/:dayid/:id' do
  require_admin
  page = :dayid
  day = Group.get(params[:dayid])
  promotion = day.promotions.get(params[:id])
  unless promotion.nil?
    promotion.destroy
  end
  redirect "/admin/day/show/#{day.id}"
end

get '/admin/day/votes/show/:dayid/:id' do
  require_admin
  @day = Group.get(params[:dayid])
  @product = @day.products.get(params[:id])
  @votes = @product.votes.all
  erb :"admin/votes/show", :layout => :admin
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

