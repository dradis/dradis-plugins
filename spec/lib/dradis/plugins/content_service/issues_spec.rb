require 'rails_helper'

# These specs are coming from engines/dradispro-rules/spec/content_service_spec.rb
# To run, execute from Dradis main app folder:
#   bin/rspec [dradis-plugins path]/spec/lib/dradis/plugins/content_service/issues_spec.rb

describe Dradis::Plugins::ContentService::Base do
  let(:plugin)  { Dradis::Plugins::Nessus }
  let(:default_issue_state) { :draft }
  let(:service) do
    Dradis::Plugins::ContentService::Base.new(
      default_issue_state: default_issue_state,
      plugin: plugin,
      logger: Rails.logger,
      project: create(:project)
    )
  end
  let(:cache) { service.issue_cache }

  describe 'Issues' do
    let(:plugin_name) { plugin::Engine::plugin_name }
    let(:plugin_id) { '1234' }
    let(:cache_key) { [plugin_name, plugin_id].join('-') }

    let(:create_issue) do
      service.create_issue(id: plugin_id)
    end

    after do
      cache.delete(cache_key)
    end

    describe 'when the issue already exists in the cache' do
      let(:existing_issue) { create(:issue, text: 'Test issue' ) }
      before { cache.store(cache_key, existing_issue) }

      it "doesn't create a new issue" do
        expect{create_issue}.not_to change{Issue.count}
      end
    end

    describe "when the issue doesn't already exist in the cache" do
      let(:plugin_id) { '0' }

      it "creates a new Issue containing 'plugin' and 'plugin_id'" do
        new_issue = nil
        expect{new_issue = create_issue}.to change{Issue.count}.by(1)
        expect(new_issue.text).to match(/#\[plugin\]#\n*#{plugin_name}/)
        expect(new_issue.text).to match(/#\[plugin_id\]#\n*#{plugin_id}/)
      end

      it 'adds the new finding to the cache' do
        finding = create_issue
        expect(cache[cache_key]).to eq finding
      end
    end

    describe 'issue states' do
      let(:plugin_id) { '1' }

      it 'creates an issue with the default state' do
        issue = create_issue
        expect(issue.state).to eq(default_issue_state.to_s)
      end
    end
  end
end
