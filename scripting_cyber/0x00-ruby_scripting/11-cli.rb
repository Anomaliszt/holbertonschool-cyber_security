#!/usr/bin/env ruby

require 'optparse'

def load_tasks
  if File.exist?('tasks.txt')
    File.readlines('tasks.txt').map(&:chomp)
  else
    []
  end
end

def save_tasks(tasks)
  File.open('tasks.txt', 'w') do |file|
    tasks.each { |task| file.puts(task) }
  end
end

def add_task(task)
  tasks = load_tasks
  tasks << task
  save_tasks(tasks)
  puts "Task '#{task}' added."
end

def list_tasks
  tasks = load_tasks
  if tasks.empty?
    puts "No tasks available."
  else
    puts "Tasks:"
    tasks.each_with_index { |task, index| puts "#{index + 1}. #{task}" }
  end
end

def remove_task(index)
  tasks = load_tasks
  if index.between?(1, tasks.length)
    removed_task = tasks.delete_at(index - 1)
    save_tasks(tasks)
    puts "Task '#{removed_task}' removed."
  else
    puts "Invalid task index."
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: cli.rb [options]"

  opts.on("-a", "--add TASK", "Add a new task") do |task|
    options[:add] = task
  end

  opts.on("-l", "--list", "List all tasks") do
    options[:list] = true
  end

  opts.on("-r", "--remove INDEX", "Remove a task by index") do |index|
    options[:remove] = index.to_i
  end

  opts.on("-h", "--help", "Show help") do
    puts opts
    exit
  end
end.parse!

if options[:add]
  add_task(options[:add])
elsif options[:list]
  list_tasks
elsif options[:remove]
  remove_task(options[:remove])
else
  puts "Usage: cli.rb [options]"
end
