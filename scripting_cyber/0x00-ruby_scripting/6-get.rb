#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'

def get_request(url)
  uri = URI(url)

  http = Net::HTTP.new(uri.host, uri.port)

  http.use_ssl = (uri.scheme == 'https')

  request = Net::HTTP::Get.new(uri.request_uri)

  response = http.request(request)

  puts "Response status: #{response.code} #{response.message}"

  puts "Response body:"

  begin
    json_response = JSON.parse(response.body)
    puts JSON.pretty_generate(json_response)
  rescue JSON::ParserError
    puts response.body
  end
end
