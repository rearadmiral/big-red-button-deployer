require_relative '../lib/go_cd/pipeline'
require 'go_cd/stage_run'
require 'ostruct'

module GoCD
  describe Pipeline do

    let(:materials) do
      [OpenStruct.new(repository_url: 'http://git.osito.org/app', commits: [OpenStruct.new(revision: 'abc123')])]
    end

    let(:api_pipeline) do
      OpenStruct.new(materials: materials, counter: 2, name: 'upstream-o-rama')
    end

    let(:fake_stage) do
      OpenStruct.new(completed_at: Time.now, pipeline: api_pipeline, name: 'stage-o-rama', counter: 3, pipeline: api_pipeline)
    end

    let(:upstream_build) do
      StageRun.new(fake_stage)
    end

    let(:pipeline) do
      Pipeline.new(name: 'deploy-o-rama', host: 'go.bonito.org')
    end

    it "has a schedule url" do
      expect(pipeline.schedule_url).to eq "https://go.bonito.org/go/api/pipelines/deploy-o-rama/schedule"
    end

    it "allows you to set materials from a green build" do
      pipeline.use_materials_from upstream_build
      expect(pipeline.upstream_pipeline.counter).to eq 2
      expect(pipeline.upstream_pipeline.name).to eq "upstream-o-rama"
      expect(pipeline.schedule_url).to include "materials[app-git]=abc123"
      expect(pipeline.schedule_url).to include "materials[upstream-o-rama]=upstream-o-rama/2/stage-o-rama/3"
    end

  end
end
