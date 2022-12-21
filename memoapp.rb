# frozen_string_literal: true

require 'bundler/setup'
require 'json'
require 'pg'
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

USER = 'testuser'
DBNAME = 'memoapp'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  conn = create_connection
  @memos = load_data(conn)
  erb :top
end

get '/memo/compose' do
  erb :new_memo
end

post '/memo/compose' do
  conn = create_connection
  id = insert_data(conn, params[:title], params[:memo])
  redirect "/memo/#{id}"
end

get '/memo/:id' do
  conn = create_connection
  memos = load_data(conn)
  @id = params[:id]
  @memo = memos[@id]
  erb :show_memo
end

get '/memo/:id/edit' do
  conn = create_connection
  memos = load_data(conn)
  @id = params[:id]
  @memo = memos[@id]
  erb :edit_memo
end

patch '/memo/:id' do
  conn = create_connection
  update_data(conn, params[:title], params[:memo], params[:id])
  redirect "/memo/#{params[:id]}"
end

delete '/memo/:id' do
  conn = create_connection
  delete_data(conn, params[:id])
  redirect '/'
end

def create_connection
  PG::Connection.connect(user: USER, dbname: DBNAME)
end

def load_data(conn)
  memos = {}
  conn.exec('SELECT * FROM memo').each do |result|
    memos[result['id']] = { title: result['title'], memo: result['memo'] }
  end
  memos
end

def insert_data(conn, title, memo)
  query = 'INSERT INTO memo(title, memo) VALUES($1, $2) RETURNING id;'
  param = [title, memo]
  id = ''
  conn.exec_params(query, param).each do |result|
    id = result['id']
  end
  id
end

def update_data(conn, title, memo, id)
  query = 'UPDATE memo SET title = $1, memo = $2 WHERE id = $3;'
  param = [title, memo, id]
  write_data(conn, query, param)
end

def delete_data(conn, id)
  query = 'DELETE FROM memo WHERE id = $1;'
  param = [id]
  write_data(conn, query, param)
end

def write_data(conn, query, param)
  conn.exec_params(query, param)
end
