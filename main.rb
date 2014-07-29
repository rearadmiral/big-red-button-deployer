require_relative 'lib/listener'
require_relative 'lib/go_cd/config'
require_relative 'lib/go_cd/http'

config = GoCD::Config.from_file('./config.yml')

puts "Sending test request..."
GoCD::Http.get("https://#{config.server.host}/go/cctray.xml", config.auth_options) { puts "Success!" }

Listener.new(config).start
