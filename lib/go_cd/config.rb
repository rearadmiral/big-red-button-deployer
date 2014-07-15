require 'ostruct'
require 'highline/import'

module GoCD

  class Config

    attr_reader :auth_options, :server, :upstream_pipeline, :deployment_pipeline, :countdown_in_seconds

    def self.from_file(filename)
      config = YAML.load(File.read(filename))
      Config.new(config)
    end

    def initialize(hash)
      @config = hash
      username = @config['go-server']['username']
      @server = OpenStruct.new(host: @config['go-server']['host'])
      @auth_options = { username: username, password: prompt_for_password(for: "#{username}@#{@server.host}") }
      @upstream_pipeline = OpenStruct.new(name: @config['upstream-pipeline']['name'], stage: @config['upstream-pipeline']['stage']) if @config['upstream-pipeline']
      @deployment_pipeline = OpenStruct.new(name: @config['deployment-pipeline']['name'])
      @countdown_in_seconds = @config['countdown_in_seconds'] || 3
    rescue
      puts "Error loading config:"
      p @config
      raise
    end

    private

    def prompt_for_password(opts)
      ask("enter password for #{opts[:for]}: ") { |prompt| prompt.echo = false }
    end

  end

end
