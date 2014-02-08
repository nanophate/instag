require 'open-uri'
require 'uri'
require 'pp'

require 'rubygems'
require 'json'
require 'sinatra'
require 'sinatra/r18n'

before do

  @target_tag = params[:t]
  @target_path = "/#{@target_tag}"
  @target_url  = "https://api.instagram.com/v1/tags#{@target_path}/media/recent?access_token="
  @base_url    = @target_url + '991739590.0a32e18.3beed1e07ec24441bf5c7901259d4067'
  @data        = []
  @error       = false

  # sinatra-r18n
  set :translations, "./i18n/tag/"
end

get '/start' do
  erb :index
end

get '/' do
  create_data
  erb :index
end

put '/' do
  create_data(params[:max_id])
  erb :index
end


get '/error' do
  @error = true
  erb :error
end

private
def create_data(max_id = nil)
  json = parse_json(create_max_id_url(max_id))

  redirect '/start' unless json['meta']['code'] && json['meta']['code'] == 200

  @data = extract_data(json['data'])
  @max_id = check_id(json['pagination']['next_max_id'])
end

def create_max_id_url(max_id = nil)
  return @base_url unless max_id
  @base_url + "&max_id=#{max_id}"
end

def check_id(max_id)
  return nil unless max_id
  begin
    return max_id if max_id == max_id.to_i.to_s
  rescue
    redirect '/start' #TODO
  end
  nil
end

def parse_json(url)
  begin
    str = open(url) do |data|
      data.read
    end
  rescue
    redirect '/start' #TODO
  end

  begin
    json = JSON.parse(str)
  rescue
    redirect '/start' #TODO
  end
  json
end

def extract_data(data)
  redirect '/start' if data.empty? #TODO

  result = []
  data.each do |v|
    hash = {}
    hash['thumbnail']    = v['images']['thumbnail']['url']
    hash['low']          = v['images']['low_resolution']['url']
    hash['standard']     = v['images']['standard_resolution']['url']
    hash['created_time'] = v['created_time']
    hash['link']         = v['link']
    hash['likes']        = v['likes']
    hash['location']     = v['location']
    hash['caption']      = v['caption'] ? v['caption']['text'] : nil

    result.push hash
  end
  result
end
