require 'sinatra'
require 'sinatra/reloader'
require 'pg'

require_relative 'models/recipe'
require_relative 'models/ingredient'


configure :development, :test do
  require 'pry'
end

def db_connection
  begin
    connection = PG.connect(dbname: "recipes")
    yield(connection)
  ensure
    connection.close
  end
end

get '/' do
  erb :'index'
end

get '/recipes' do
  @recipes = Recipe.all
  erb :'recipes/index'
end

get '/recipes/:id' do
  @recipe = Recipe.find(params[:id])
  erb :'recipes/show'
end
