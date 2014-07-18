module GoCD

  class Stage

    attr_reader :name, :pipeline_name, :pipeline_counter

    def initialize(options)
      @host = options[:host]
      @name = options[:name]
      @pipeline_name = options[:pipeline_name]
      @pipeline_counter = options[:pipeline_counter]
    end

    def trigger_url
      "https://#{@host}/go/run/#{@pipeline_name}/#{@pipeline_counter}/#{@name}"
    end

  end

end
