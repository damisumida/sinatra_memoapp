# frozen_string_literal: true

# myapp.rb
require 'bundler/setup'
require 'json'
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

get '/' do
  @memos = load_data['memos']
  erb :top
end

get '/memo/compose' do
  erb :newmemo
end

post '/memo/compose' do
  title = params[:title]
  memo = params[:memo]
  data = load_data
  id = calc_maxid(data)
  newmemo = { 'id' => id.to_i, 'title' => title, 'memo' => memo }
  data['memos'].push(newmemo)
  File.open('db/data.json', 'w') do |file| 
    file.write(JSON.generate(data))
  end
  redirect to "/"
end

get '/memo/:id' do
  @id = params[:id]
  @title = load_title(@id)
  @memo = load_memo(@id)
  erb :showmemo
end

get '/memo/:id/edit' do
  @id = params[:id]
  @title = load_title(@id)
  @memo = load_memo(@id)
  erb :editmemo
end

patch '/memo/:id' do
  rewrit_memo = { 'id' => params[:id].to_i, 'title' => params[:title], 'memo' => params[:memo] }
  rewrite_memos = create_rewrite_memos(id, rewrit_memo)
  File.open('db/data.json', 'w') do |file|
    file.write(JSON.generate(rewrite_memos))
  end
  @memos = rewrite_memos['memos']
  redirect to "/"
end

delete '/memo/:id' do
  id = params[:id]
  data = load_data
  data['memos'].each do |memo|
    data['memos'].delete(memo) if id.to_i == memo['id']
  end
  File.open('db/data.json', 'w') do
    |file| file.write(JSON.generate(data))
  end
  redirect to "/"
end

def calc_maxid(data)
  id = 0
  data['memos'].each do |item|
    id = item['id'] if item['id'] > id.to_i
  end
  id += 1
end

def load_data
  data = ''
  File.open('db/data.json') do |file|
    data = file.read
    data = JSON.parse(data)
  end
  data
end

def load_title(id)
  title = ''
  data = load_data
  data['memos'].each do |item|
    title = item['title'] if item['id'] == id.to_i
  end
  title
end

def load_memo(id)
  memo = ''
  data = load_data
  data['memos'].each do |item|
    memo = item['memo'] if item['id'] == id.to_i
  end
  memo
end

def create_rewrite_memos(id, rewrit_memo)
  data = load_data
  data['memos'].each do |memo, i|
    data['memos'][i+1] = rewrit_memo if id.to_i == memo['id']
  end
  data
end
