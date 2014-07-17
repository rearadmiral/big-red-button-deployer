require_relative '../lib/go_cd/stage'

module GoCD

  describe Stage do

    let(:stage) do
      Stage.new host: 'go.osito.org', name: 'release-it', pipeline_name: 'prod-deploy-pipeline', pipeline_counter: 2
    end

    it "knows its own trigger url" do
      expect(stage.trigger_url).to eq "https://go.osito.org/go/run/prod-deploy-pipeline/2/release-it"
    end

  end

end
