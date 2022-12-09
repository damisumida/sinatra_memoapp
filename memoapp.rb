# frozen_string_literal: true

require 'bundler/setup'
require 'json'
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

DATA_FILE_PATH = 'data/data.json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  @memos = load_memos
  erb :top
end

get '/memo/compose' do
  erb :new_memo
end

post '/memo/compose' do
  memos = load_memos
  id = calc_maxid(memos)
  memos[id] = { 'title' => params[:title], 'memo' => params[:memo] }
  write_data(memos)
  redirect "/memo/#{id}"
end

get '/memo/:id' do
  @id = params[:id]
  memos = load_memos
  @memo = memos[@id]
  erb :show_memo
end

get '/memo/:id/edit' do
  @id = params[:id]
  memos = load_memos
  @memo = memos[@id]
  erb :edit_memo
end

patch '/memo/:id' do
  id = params[:id]
  memos = load_memos
  new_memo = { 'title' => params[:title], 'memo' => params[:memo] }
  memos[id] = new_memo
  write_data(memos)
  redirect "/memo/#{id}"
end

delete '/memo/:id' do
  id = params[:id]
  memos = load_memos
  memos.delete(id)
  write_data(memos)
  redirect '/'
end

def calc_maxid(memos)
  ids = memos.keys.map(&:to_i)
  ids.empty? ? 1 : ids.max + 1
end

def load_memos
  write_data({}) unless File.exist?(DATA_FILE_PATH)
  File.open(DATA_FILE_PATH) do |file|
    JSON.parse(file.read)
  end
end

def write_data(memos)
  File.open(DATA_FILE_PATH, 'w') do |file|
    file.write(JSON.generate(memos))
  end
end
