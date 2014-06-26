require 'rubygems'
require 'bundler'

Bundler.setup

require 'dream_cheeky'
require 'go_api_client'
require 'os'

puts "finding button..."

class BaseHandler

  def push
    GoApiClient.schedule_pipeline(:host => 'go01.thoughtworks.com', :pipeline_name => 'deploy-pasty')
  end

end

class WindowsHandler < BaseHandler

  def open

  end

  def close
  end

end

class OsxHandler < BaseHandler
  def open

  end

  def close

  end
end

handler = OS.windows? ? WindowsHandler.new : OsxHandler.new

DreamCheeky::BigRedButton.run do

  puts "listening for events..."

  open do
    puts "EVENT: lid opened"
    handler.open
  end

  push do
    puts "EVENT: button pushed"
    handler.push
  end

  close do
    puts "EVENT: lid closed"
    handler.close
  end

end
