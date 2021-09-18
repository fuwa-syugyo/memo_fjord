#! /usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'erb'
enable :method_override

hash_array = []
json_file_path = 'memo.json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

class Memo
  attr_accessor :title, :description

  def initialize(title, _disctiption)
    @title = title
    @description = description
  end

  def self.uuid
    SecureRandom.uuid
  end
end

get '/memos' do
  erb :erb_top_page, locals: { md: markdown(:erb_and_md_template_page) }
end

get '/memos/new' do
  erb :erb_new_memo_page, locals: { md: markdown(:erb_and_md_template_page) }
end

post '/memos' do
  @title = params[:title]
  @description = params[:description]

  memo_cul = File.open(json_file_path) do |io|
    JSON.parse(io.read)
  end

  File.open(json_file_path, 'w') do |file|
    hash_array = memo_cul.to_a

    hash = { id: Memo.uuid, title: @title, description: @description }
    hash_array << hash
    JSON.dump(hash_array, file)
  end

  redirect 'http://localhost:4567/memos'
  erb :erb_top_page, locals: { md: markdown(:erb_and_md_template_page) }
end

get '/memos/:id' do
  erb :erb_show_memo_page, locals: { md: markdown(:erb_and_md_template_page) }
end

get '/memos/:id/edit' do
  @id = params[:id]

  buffer = File.open(json_file_path, 'r') do |file|
    JSON.parse(file.read)
  end
  @memo_hash = buffer.find { |hash| hash['id'] == @id }

  erb :erb_edit_memo_page, locals: { md: markdown(:erb_and_md_template_page) }
end

patch '/memos/:id' do
  @id = params[:id]
  @edited_title = params[:edited_title]
  @edited_description = params[:edited_description]
  cur_url = request.path.delete_prefix('/memos/')

  memo_data = File.open(json_file_path) do |io|
    JSON.parse(io.read)
  end

  memo_hash = memo_data.find { |hash| hash['id'] == cur_url }

  memo_hash['title'] = @edited_title
  memo_hash['description'] = @edited_description

  File.open(json_file_path, 'w') do |io|
    JSON.dump(memo_data, io)
  end

  redirect redirect 'http://localhost:4567/memos'
  erb :erb_top_page, locals: { md: markdown(:erb_and_md_template_page) }
end

delete '/memos/:id' do
  cur_url = request.path.delete_prefix('/memos/')

  memo_data = File.open(json_file_path) do |io|
    JSON.parse(io.read)
  end

  memo_data.delete_if { |hash| hash['id'] == cur_url }

  File.open(json_file_path, 'w') do |io|
    JSON.dump(memo_data, io)
  end

  redirect 'http://localhost:4567/memos'
end

not_found do
  erb :notFound
end
