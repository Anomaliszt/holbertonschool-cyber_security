#!/usr/bin/env ruby

require 'open-uri'
require 'uri'
require 'fileutils'

if ARGV.length != 2
  puts "Usage: #{File.basename($0)} URL LOCAL_FILE_PATH"
  exit 1
end

url, local_path = ARGV

begin
  uri = URI.parse(url)

  puts "Downloading file from #{url}..."
  File.open(local_path, "wb") do |file|
    file.write(uri.open.read)
  end

  puts "File downloaded and saved to #{local_path}."
rescue => e
  puts "Error: #{e.message}"
end
