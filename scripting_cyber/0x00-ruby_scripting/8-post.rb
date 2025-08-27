#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'

def post_request(url, body_params)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")

  request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
  request.body = body_params.to_json

  response = http.request(request)

  if response.code.to_i == 404
    puts "Response status: #{response.code} #{response.message}"
    puts "Response body:"
    puts "{}"
  else
    puts "Response status: #{response.code} #{response.message}"
    puts "Response body:"
    puts JSON.pretty_generate(JSON.parse(response.body))
  end
end
