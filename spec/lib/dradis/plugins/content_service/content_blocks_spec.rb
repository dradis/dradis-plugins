require 'rails_helper'

# To run, execute from Dradis Pro main app folder:
#   bin/rspec [dradis-plugins path]/spec/lib/dradis/plugins/content_service/content_blocks_spec.rb

describe 'Content Block content service' do
  let(:plugin) { Dradis::Plugins::Nessus }
  let(:plugin_id) { '111' }
  let(:project) { create(:project) }
  let(:service) do
    Dradis::Plugins::ContentService::Base.new(
      plugin:,
      logger: Rails.logger,
      project:
    )
  end

  describe '#all_content_blocks' do
    before do
      @draft_content = create_list(:content_block, 10, project: project, state: :draft)
      @review_content = create_list(:content_block, 10, project: project, state: :ready_for_review)
      @published_content = create_list(:content_block, 10, project: project, state: :published)
    end

    it 'returns only the published content blocks' do
      expect(service.all_content_blocks.to_a).to match_array(@published_content)
    end
  end
end
