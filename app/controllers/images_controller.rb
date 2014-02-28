require 'open-uri'
require 'uri'
require 'pp'

require 'rubygems'
require 'json'

class ImagesController < ApplicationController
  def index
		@target_tag = params[:tag]
		@target_path = "/#{@target_tag}"
		@target_url  = "https://api.instagram.com/v1/tags#{@target_path}/media/recent?access_token="
		#@target_url  = "https://api.instagram.com/v1/tags/cat/media/recent?access_token="
		@base_url    = @target_url + "ENV['PASWORD']" 
		@data        = []
		@error       = false
		if @target_tag != nil
			create_data
		end
	end

	private
	def create_data(max_id = nil)
		json = parse_json(create_max_id_url(max_id))
		#redirect '/start' unless json['meta']['code'] && json['meta']['code'] == 200
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
  #  redirect '/start' #TODO
  end

  begin
    json = JSON.parse(str)
  rescue
   # redirect '/start' #TODO
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
end
