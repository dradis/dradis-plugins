require 'rails_helper'

# These specs are coming from engines/dradispro-rules/spec/content_service_spec.rb

describe Dradis::Plugins::ContentService::Base do
  describe "Issues" do
    let(:create_issue) do
      service.create_issue_without_callback(id: plugin_id)
    end

    # Remember: even though we're calling create_issue_without_callback,
    # that method will still call issue_cache_with_callback internally.
    # So when we store an issue in the issue_cache/finding_cache below,
    # it's being stored within an instance of FindingCache, which
    # automatically wraps Issues in Findings.

    describe "when the issue already exists in the cache" do
      let(:existing_issue) { create(:issue, text: cached_issue_text) }
      before { cache.store(existing_issue) }

      it "doesn't create a new issue" do
        expect{create_issue}.not_to change{Issue.count}
      end

      it "returns the cached issue encapsulated in a finding" do
        finding = create_issue
        expect(finding).to be_a(Finding)
        expect(finding).to eq Finding.from_issue(existing_issue)
      end
    end

    describe "when the issue doesn't already exist in the cache" do
      it "creates a new Issue containing 'plugin' and 'plugin_id'" do
        new_issue = nil
        expect{new_issue = create_issue}.to change{Issue.count}.by(1)
        expect(new_issue.body).to match(/#\[plugin\]#\n*#{plugin_name}/)
        expect(new_issue.body).to match(/#\[plugin_id\]#\n*#{plugin_id}/)
      end

      it "returns the new Issue encapsulated in a Finding" do
        finding = create_issue
        expect(finding).to be_a(Finding)
        expect(finding).to eq Finding.from_issue(Issue.last)
      end

      it "adds the new Finding to the cache" do
        finding = create_issue
        expect(cache[cache_key]).to eq finding
      end
    end
  end
end
