# frozen_string_literal: true

require 'bundler/setup'
require 'json'
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  @memos = load_data
  erb :top
end

get '/memo/compose' do
  erb :new_memo
end

post '/memo/compose' do
  data = load_data
  id = calc_maxid(data)
  data[id] = { 'title' => params[:title], 'memo' => params[:memo] }
  write_data(data)
  redirect "/memo/#{id}"
end

get '/memo/:id' do
  @id = params[:id]
  memos = load_data
  @memo = memos[@id]
  erb :show_memo
end

get '/memo/:id/edit' do
  @id = params[:id]
  memos = load_data
  @memo = memos[@id]
  erb :edit_memo
end

patch '/memo/:id' do
  id = params[:id]
  memos = load_data
  new_memo = { 'title' => params[:title], 'memo' => params[:memo] }
  memos[id] = new_memo
  write_data(memos)
  redirect "/memo/#{id}"
end

delete '/memo/:id' do
  id = params[:id]
  data = load_data
  data.delete(id)
  write_data(data)
  redirect '/'
end

def calc_maxid(data)
  id = data.keys
  id.map!(&:to_i)
  id = [0] if id.empty?
  id.max + 1
end

def load_data
  create_file unless File.exist?('data/data.json')
  File.open('data/data.json') do |file|
    JSON.parse(file.read)
  end
end

def write_data(data)
  File.open('data/data.json', 'w') do |file|
    file.write(JSON.generate(data))
  end
end

def create_file
  File.open('data/data.json', 'w') do |file|
    file.write('{}')
  end
end
