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

  describe 'Evidence' do
    let(:create_evidence) do
      service.create_evidence(content: "#[Title]#\nTest Evidence\n", issue: issue, node: node, state: :ready_for_review)
    end

    describe 'when the evidence already exists' do
      before do
        @existing = create(:evidence, node: node, issue: issue, content: "#[Title]#\nTest Evidence\n", state: :published)
      end

      it 'does not create a new evidence record' do
        expect { create_evidence }.not_to change { Evidence.count }
      end

      it 'does not change the state of the existing record' do
        create_evidence
        expect(@existing.reload.state).to eq('published')
      end
    end

    describe "when the evidence doesn't already exist" do
      it 'creates a new Evidence record with the given state' do
        expect { create_evidence }.to change { Evidence.count }.by(1)
      end

      it "sets the new record's state from the :state argument" do
        expect(create_evidence.state).to eq('ready_for_review')
      end
    end

    describe "when :state isn't given" do
      it "defaults to the service's state" do
        service = Dradis::Plugins::ContentService::Base.new(
          plugin: plugin,
          logger: Rails.logger,
          project: project,
          state: :published
        )

        evidence = service.create_evidence(content: "#[Title]#\nTest Evidence\n", issue: issue, node: node)

        expect(evidence.state).to eq('published')
      end
    end
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

  describe '#evidence_for' do
    let(:other_issue) { create(:issue, node: project.issue_library) }

    let!(:published_evidence) { create(:evidence, node: node, issue: issue, state: :published) }
    let!(:draft_evidence) { create(:evidence, node: node, issue: issue, state: :draft) }
    let!(:other_issue_evidence) { create(:evidence, node: node, issue: other_issue, state: :published) }

    it "returns only the given issue's evidence" do
      expect(service.evidence_for(issue)).to match_array([published_evidence])
      expect(service.evidence_for(other_issue)).to match_array([other_issue_evidence])
    end

    it 'only fetches #all_evidence once across multiple calls' do
      expect(service).to receive(:all_evidence).once.and_call_original

      service.evidence_for(issue)
      service.evidence_for(other_issue)
    end
  end
end
