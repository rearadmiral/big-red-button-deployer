require 'rubygems'
require 'bundler'

Bundler.setup

require 'dream_cheeky'
require 'highline/import'
require 'httparty'

puts "finding button..."

username = ENV['USERNAME'] || raise("Please specify env variable USERNAME")
host = ENV['GO_HOST'] || raise("Please specifiy env variable GO_HOST")
pipeline = ENV['PIPELINE'] || raise("Please specify env variable PIPELINE")

password = ask("enter go password for #{username}: ") { |prompt| prompt.echo = false }

AUTH_OPTIONS = { :basic_auth => { :username => username, :password => password } }

test_url = "https://#{host}/go/cctray.xml"
SCHEDULE_PIPELINE_URL = "https://#{host}/go/api/pipelines/#{pipeline}/schedule"
puts "Sending test request..."
r = HTTParty.get(test_url, AUTH_OPTIONS)
if r.code >= 400
  puts "Test failed."
  puts r.parsed_response
  exit -1
end
puts "Success!"


puts "Test request succeeded."

class Handler
  def open
    `open dive_horn.mp3`
  end

  def push
    r = HTTParty.post(SCHEDULE_PIPELINE_URL, AUTH_OPTIONS)
    if r.code == 202
      puts "Pipeline scheduled."
    else
      puts "Pipeline schedule failed."
      puts r.parsed_response
      exit -1
    end
  end

  def close
  end
end

handler = Handler.new

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
