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
"Hi from the Sinatra app default route"
end

get '/vote' do
"this a vote page"
end



