module Dradis::Plugins::ContentService
  module Evidence
    extend ActiveSupport::Concern

    def create_evidence(args={})
      content = args.fetch(:content, default_evidence_content)
      node    = args.fetch(:node, default_node_parent)
      issue   = args.fetch(:issue, default_evidence_issue)

      evidence = node.evidence.new(issue_id: issue.id, content: content)

      if evidence.valid?
        evidence.save
      else
        try_rescue_from_length_validation(
          model: evidence,
          field: :content,
          text: content,
          msg: 'Error in create_evidence()'
        )
      end

      evidence
    end

    private

    def default_evidence_content
      "create_evidence() invoked by #{plugin} without a :content parameter"
    end

    def default_evidence_issue
      create_issue(text: "#[Title]#\nAuto-generated issue.\n\n#[Description]#\ncreate_evidence() invoked by #{plugin} without an :issue parameter")
    end
  end
end
