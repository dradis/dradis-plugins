require 'rails_helper'

# To run, execute from Dradis Pro main app folder:
#   bin/rspec [dradis-plugins path]/spec/lib/dradis/plugins/content_service/evidence_spec.rb

describe 'Evidence content service' do
  let(:plugin) { Dradis::Plugins::Nessus }
  let(:plugin_id) { '111' }
  let(:project) { create(:project) }
  let(:node) { create(:node, project: project) }
  let(:issue) { create(:issue, node: project.issue_library) }
  let(:service) do
    Dradis::Plugins::ContentService::Base.new(
      plugin: plugin,
      logger: Rails.logger,
      project: project
    )
  end

  describe '#all_evidence' do
    before do
      @draft_evidence = create_list(:evidence, 10, node: node, issue: issue, state: :draft)
      @review_evidence = create_list(:evidence, 10, node: node, issue: issue, state: :ready_for_review)
      @published_evidence = create_list(:evidence, 10, node: node, issue: issue, state: :published)
    end

    it 'returns only the published evidence' do
      expect(service.all_evidence.to_a).to match_array(@published_evidence)
    end
  end
end
