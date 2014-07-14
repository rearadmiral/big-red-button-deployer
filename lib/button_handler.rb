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
    # `open dive_horn.mp3`
    # `say "about to deploy revision #{upstream_revision}"`
    url = deploy_url
    puts "requesting deploy => #{url}"
    GoCD::Http.post(url, @config.auth_options) do |response|
      puts response.parsed_response
    end
  end

  def push
    `open liftoff.mp3`

  end

  def close
    `say "cancelled"`
  end

  private

  def deploy_url
    "https://#{@config.server.host}/go/api/pipelines/#{@config.deployment_pipeline.name}/schedule?#{upstream_material_params}"
  end

  def upstream_material_params
    last_green_build = @fetcher.fetch
    git_revisions = last_green_build.materials.inject({}) do |memo, git_material|
      repo_name = git_material.repository_url.split('/').last
      default_material_name = "#{repo_name}-git"
      memo[default_material_name] = git_material.commits.first.revision
      memo
    end
    { @config.upstream_pipeline.name => last_green_build.instance  }.merge(git_revisions).map do |name, value|
      "materials[#{name}]=#{value}"
    end.join("&")
  end


end
