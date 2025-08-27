#!/usr/bin/env ruby

require 'json'

def merge_json_files(file1_path, file2_path)
  data1 = JSON.parse(File.read(file1_path))
  data2 = JSON.parse(File.read(file2_path))

  merged_data = data2 + data1

  File.open(file2_path, 'w') do |f|
    f.write(JSON.pretty_generate(merged_data))
  end

  puts "Merged JSON written to #{file2_path}"
end
