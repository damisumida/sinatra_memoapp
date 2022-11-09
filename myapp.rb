# frozen_string_literal: true

# myapp.rb
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
  @memos = load_data['memos']
  erb :top
end

get '/memo/compose' do
  erb :newmemo
end

post '/memo/compose' do
  data = load_data
  id = calc_maxid(data)
  newmemo = { 'id' => id.to_i, 'title' => params[:title], 'memo' => params[:memo] }
  data['memos'].push(newmemo)
  write_data(data)
  redirect to "/memo/#{id}"
end

get '/memo/:id' do
  id = params[:id]
  @memo = load_memo(id)
  p @memo
  erb :showmemo
end

get '/memo/:id/edit' do
  id = params[:id]
  @memo = load_memo(id)
  erb :editmemo
end

patch '/memo/:id' do
  rewrit_memo = { 'id' => params[:id].to_i, 'title' => params[:title], 'memo' => params[:memo] }
  rewrite_memos = create_rewrite_memos(params[:id], rewrit_memo)
  write_data(rewrite_memos)
  @memos = rewrite_memos['memos']
  redirect to "/memo/#{params[:id]}"
end

delete '/memo/:id' do
  id = params[:id]
  data = load_data
  data['memos'].each do |memo|
    data['memos'].delete(memo) if id.to_i == memo['id']
  end
  write_data(data)
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

def load_memo(id)
  memo = ""
  data = load_data
  data['memos'].each do |m|
    memo = m if m['id'] == id.to_i
  end
  memo
end

def create_rewrite_memos(id, rewrit_memo)
  data = load_data
  data['memos'].each do |memo, i=0|
    data['memos'][i+1] = rewrit_memo if id.to_i == memo['id']
  end
  data
end

def write_data(data)
  File.open('db/data.json', 'w') do |file|
    file.write(JSON.generate(data))
  end
end
