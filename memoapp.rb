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
  newmemo = { 'id' => id, 'title' => params[:title], 'memo' => params[:memo] }
  data['memos'].push(newmemo)
  write_data(data)
  redirect to "/memo/#{id}"
end

get '/memo/:id' do
  id = params[:id]
  @memo = load_memo(id)
  erb :showmemo
end

get '/memo/:id/edit' do
  id = params[:id]
  @memo = load_memo(id)
  erb :editmemo
end

patch '/memo/:id' do
  id = params[:id].to_i
  rewrit_memo = { 'id' => id, 'title' => params[:title], 'memo' => params[:memo] }
  rewrite_memos = create_rewrite_memos(id, rewrit_memo)
  write_data(rewrite_memos)
  @memos = rewrite_memos['memos']
  redirect to "/memo/#{id}"
end

delete '/memo/:id' do
  id = params[:id].to_i
  data = load_data
  data['memos'].each do |memo|
    data['memos'].delete(memo) if id == memo['id']
  end
  write_data(data)
  redirect to '/'
end

def calc_maxid(data)
  id = data['memos'].map { |memo| memo['id'] }
  id = [0] if id.empty?
  id.max + 1
end

def load_data
  create_datajson unless File.exist?('data/data.json')
  File.open('data/data.json') do |file|
    JSON.parse(file.read)
  end
end

def load_memo(id)
  memo = ''
  load_data['memos'].each do |m|
    memo = m if m['id'] == id.to_i
  end
  memo
end

def create_rewrite_memos(id, rewrit_memo)
  data = load_data
  data['memos'].each_with_index do |memo, i|
    data['memos'][i] = rewrit_memo if id == memo['id']
  end
  data
end

def write_data(data)
  File.open('data/data.json', 'w') do |file|
    file.write(JSON.generate(data))
  end
end

def create_datajson
  File.open('data/data.json', 'w') do |file|
    file.write('{"memos":[]}')
  end
end
