require_relative 'go_cd/http'
require 'go_cd/last_green_build_fetcher'

class ButtonHandler

  def initialize(config)
    @config = config
    @fetcher = GoCD::LastGreenBuildFetcher.new(:protocol => 'https',
                                        :host => @config.server.host,
                                        :port => 443,
                                        :username => @config.auth_options[:username],
                                        :password => @config.auth_options[:password],
                                        :pipeline_name => @config.upstream_pipeline.name,
                                        :stage_name => @config.upstream_pipeline.stage)
  end

  def open
    deployment_materials = upstream_materials
    upstream_pipeline_counter = deployment_materials[@config.upstream_pipeline.name].split('/')[1]
    `say "about to deploy materials from #{@config.upstream_pipeline.name} #{upstream_pipeline_counter.split('').join(' ')}"`
    @iminent_deploy_url = deploy_url(to_params(deployment_materials))
    puts "  will deploy => #{@iminent_deploy_url}"
    `open dive_horn.mp3`
  end

  def push
    `open liftoff.mp3`
    puts "deploying in 10 sec"
    sleep 10
    puts "deploying to #{@iminent_deploy_url}"
    GoCD::Http.post(@iminent_deploy_url, @config.auth_options) do |response|
      puts response.parsed_response
    end
    @deployed = true
  end

  def close
    if @deployed
      @deployed = false
      `say "Thank you for using the Big Red Button."`
    else
      `say "Cancelled."`
    end
    @iminent_deploy_url = nil
  end

  private

  def deploy_url(params)
    "https://#{@config.server.host}/go/api/pipelines/#{@config.deployment_pipeline.name}/schedule?#{params}"
  end

  def upstream_materials
    last_green_build ||= @fetcher.fetch
    git_revisions = last_green_build.materials.inject({}) do |memo, git_material|
      repo_name = git_material.repository_url.split('/').last
      default_material_name = "#{repo_name}-git"
      memo[default_material_name] = git_material.commits.first.revision
      memo
    end
    { @config.upstream_pipeline.name => last_green_build.instance  }.merge(git_revisions)
  end

  def to_params(materials_hash)
    materials_hash.map do |name, value|
      "materials[#{name}]=#{value}"
    end.join("&")
  end


end
