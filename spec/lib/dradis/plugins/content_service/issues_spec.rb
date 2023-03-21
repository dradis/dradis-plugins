require 'rails_helper'

# To run, execute from Dradis main app folder:
#   bin/rspec [dradis-plugins path]/spec/lib/dradis/plugins/content_service/issues_spec.rb

describe 'Issues content service' do
  let(:plugin) { Dradis::Plugins::Nessus }
  let(:plugin_id) { '111' }
  let(:project) { create(:project) }
  let(:service) do
    Dradis::Plugins::ContentService::Base.new(
      plugin: plugin,
      logger: Rails.logger,
      project: project
    )
  end

  describe 'Issues' do
    let(:create_issue) do
      service.create_issue(text: "#[Title]#\nTest Issue\n", id: plugin_id)
    end

    describe 'when the issue already exists in the cache' do
      before do
        issue = create(:issue, text: "#[Title]#\nTest Issue\n", id: plugin_id)
        service.issue_cache.store("nessus-#{plugin_id}", issue)
      end

      it 'does not create a new issue' do
        expect { create_issue }.not_to change { Issue.count }
      end
    end

    describe "when the issue doesn't already exist in the cache" do
      it "creates a new Issue containing 'plugin' and 'plugin_id'" do
        new_issue = nil
        plugin_name = "#{plugin}::Engine".constantize.plugin_name
        expect { new_issue = create_issue }.to change { Issue.count }.by(1)
        expect(new_issue.text).to match(/#\[plugin\]#\n*#{plugin_name}/)
        expect(new_issue.text).to match(/#\[plugin_id\]#\n*#{plugin_id}/)
      end
    end

    describe '#all_issues' do
      before do
        @draft_issues = create_list(:issue, 10, project: project, state: :draft)
        @review_issues = create_list(:issue, 10, project: project, state: :ready_for_review)
        @published_issues = create_list(:issue, 10, project: project, state: :published)
      end

      it 'returns only the published issues' do
        expect(service.all_issues.to_a).to match_array(@published_issues)
      end
    end
  end
end
