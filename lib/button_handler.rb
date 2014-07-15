require_relative 'go_cd/http'
require_relative 'go_cd/pipeline'
require 'go_cd/last_green_build_fetcher'


class ButtonHandler

  def initialize(config)
    @config = config
  end

  def open
    @pipeline = GoCD::Pipeline.new(name: @config.deployment_pipeline.name, host: @config.server.host)

    if @config.upstream_pipeline
      @pipeline.use_materials_from(upstream_green_build_fetcher.fetch)
      `say "about to deploy version from #{@pipeline.upstream_pipeline.name} #{@pipeline.upstream_pipeline.counter.to_s.split('').join(' ')}"`
      puts "about to deploy materials: {@pipeline.upstream_pipeline.inspect}"
      puts "the url will be: #{@pipeline.schedule_url}"
    end

  end

  def push
    return unless @pipeline
    Thread.new do
      begin
        @deploying = true
        puts "deploying in #{@config.countdown_in_seconds} seconds..."
        `say "Deploying in #{@config.countdown_in_seconds}"`
        (1..@config.countdown_in_seconds-1).to_a.reverse.each do |n|
          puts n
          `say #{n}`
          sleep 1
          if @cancel_requested
            cancel
            @cancel_requested = false
            @deploying = false
            break
          end
        end

        if @deploying
          puts "deployment API request: #{@pipeline.schedule_url}"
          GoCD::Http.post(@pipeline.schedule_url, @config.auth_options) do |response|
            puts response.parsed_response
            @deployed = true
            `say "Go is now deploying."`
          end
        else
          puts "cancelled"
        end
      rescue => e
        msg = "Error encountered: #{e}"
        `say "oops! #{msg}"`
        puts "=" * 80
        puts msg
        puts e.backtrace.join("\n")
        puts "=" * 80
        raise
      ensure
        @deploying = false
      end
    end
  end

  def close
    if @deployed
      @deployed = false
      `say "Thank you for using the Big Red Button."`
    elsif @deploying
      @cancel_requested = true
    end
    @pipeline = nil
  end

  private

  def cancel
    `say "Cancelled."`
  end

  def upstream_green_build_fetcher
    @fupstream_green_build_fetcher ||= GoCD::LastGreenBuildFetcher.new(:protocol => 'https',
                                                 :host => @config.server.host,
                                                 :port => 443,
                                                 :username => @config.auth_options[:username],
                                                 :password => @config.auth_options[:password],
                                                 :pipeline_name => @config.upstream_pipeline.name,
                                                 :stage_name => @config.upstream_pipeline.stage)

  end

end
