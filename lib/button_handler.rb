require_relative 'go_cd/http'
require_relative 'go_cd/pipeline'
require_relative 'go_cd/stage'
require 'go_cd/last_green_build_fetcher'

class ButtonHandler

  def initialize(config)
    @config = config
  end

  def open

    @pipeline = GoCD::Pipeline.new(name: @config.deployment_pipeline.name, host: @config.server.host)

    if @config.deployment_pipeline.manual_stage && @config.upstream_pipeline
      existing_stage_run = existing_pipeline_fetcher.fetch || raise("could not find existing stage with the materials specified")
      @stage = GoCD::Stage.new(pipeline_counter: existing_stage_run.pipeline_counter, name: @config.deployment_pipeline.manual_stage, pipeline_name: @config.deployment_pipeline.name, host: @config.server.host)
      `say "about to trigger #{@stage.name} stage of #{@stage.pipeline_name}, number #{@stage.pipeline_counter.to_s.split('').join(' ')}"`
      puts "about to trigger #{@stage.inspect}"
    elsif @config.upstream_pipeline
      @pipeline.use_materials_from(upstream_green_build_fetcher.fetch)
      `say "about to schedule pipeline with the same materials as #{@pipeline.upstream_pipeline.name} #{@pipeline.upstream_pipeline.counter.to_s.split('').join(' ')}"`
      puts "deploying pipeline with materials: #{@pipeline.upstream_pipeline.inspect}"
    end

    @url = @stage ? @stage.trigger_url : @pipeline.schedule_url
    @url.tap { |url| puts "will post to: #{url}" }
  end


  def push
    return unless @url
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
          GoCD::Http.post(@url, @config.auth_options) do |response|
            puts "HTTP #{response.code}: #{response.parsed_response}"
            @deployed = true
            puts "Go has scheduled the deploy"
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

  def existing_pipeline_fetcher
    @existing_pipeline_fetcher ||= GoCD::LastGreenBuildFetcher.new(:protocol => 'https',
                                                 :host => @config.server.host,
                                                 :port => 443,
                                                 :username => @config.auth_options[:username],
                                                 :password => @config.auth_options[:password],
                                                 :pipeline_name => @config.deployment_pipeline.name,
                                                 :stage_name => @config.deployment_pipeline.automatic_stage)

  end

  def upstream_green_build_fetcher
    @upstream_green_build_fetcher ||= GoCD::LastGreenBuildFetcher.new(:protocol => 'https',
                                                 :host => @config.server.host,
                                                 :port => 443,
                                                 :username => @config.auth_options[:username],
                                                 :password => @config.auth_options[:password],
                                                 :pipeline_name => @config.upstream_pipeline.name,
                                                 :stage_name => @config.upstream_pipeline.stage)

  end

end
