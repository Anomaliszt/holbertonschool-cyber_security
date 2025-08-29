#!/usr/bin/env ruby

require 'fileutils'
require 'optparse'

TASKS_FILE = 'tasks.txt'.freeze

FileUtils.touch(TASKS_FILE) unless File.exist?(TASKS_FILE)

options = {}

OptionParser.new do |option|
  option.banner = 'Usage: cli.rb [options]'

  option.on('-a', '--add TASK', 'Add a new task') do |task|
    options[:add] = task
  end

  option.on('-l', '--list', 'List all tasks') do
    options[:list] = true
  end

  option.on('-r', '--remove INDEX', Integer, 'Remove a task by index') do |index|
    options[:remove] = index
  end

  option.on('-h', '--help', 'Show help') do
    puts option
    exit
  end
end.parse!

if options[:add]
  File.open(TASKS_FILE, 'a') do |file|
    file.puts(options[:add])
  end
  puts "Task '#{options[:add]}' added."

elsif options[:list]
  tasks = File.readlines(TASKS_FILE, chomp: true)
  if tasks.empty?
    puts 'No tasks found.'
  else
    tasks.each_with_index do |task, index|
      puts "#{index + 1}. #{task}"
    end
  end

elsif options[:remove]
  index = options[:remove].to_i
  tasks = File.readlines(TASKS_FILE, chomp: true)

  if index.between?(1, tasks.size)
    removed = tasks.delete_at(index - 1)
    File.write(TASKS_FILE, tasks.join("\n") + "\n")

    puts "Task '#{removed}' removed."
  else
    puts 'Invalid index.'
  end
end
