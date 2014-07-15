module GoCD

  class Pipeline

    def initialize(options)
      @name = options[:name]
      @host = options[:host]
    end

    def schedule_url
      "https://#{@host}/go/api/pipelines/#{@name}/schedule".tap do |url|
        url << "?#{params}" if params
      end
    end

    def use_materials_from(upstream_build)
      @upstream_build = upstream_build
    end

    def upstream_pipeline
      return unless upstream_materials
      OpenStruct.new(name: @upstream_build.pipeline_name, counter: @upstream_build.pipeline_counter)
    end

    private

    def params
      return unless upstream_materials
      to_params(upstream_materials)
    end

    def upstream_materials
      return unless @upstream_build
      git_revisions = @upstream_build.materials.inject({}) do |memo, git_material|
        repo_name = git_material.repository_url.split('/').last
        default_material_name = "#{repo_name}-git"
        memo[default_material_name] = git_material.commits.first.revision
        memo
      end
      { @upstream_build.pipeline_name => @upstream_build.instance  }.merge(git_revisions)
    end

    def to_params(materials_hash)
      materials_hash.map do |name, value|
        "materials[#{name}]=#{value}"
      end.join("&")
    end

  end

end
