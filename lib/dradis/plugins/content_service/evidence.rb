module Dradis::Plugins::ContentService
  module Evidence
    extend ActiveSupport::Concern

    def all_evidence
      case scope
      when :all
        project.evidence
      when :published
        project.evidence.published
      else
        raise 'Unsupported scope!'
      end
    end

    # Returns the (already scope-filtered) Evidence belonging to the given
    # Issue. Callers with many Issues to process should prefer this over
    # `issue.evidence`, which would bypass the export's Published/All scope.
    #
    # Memoizes a materialized copy of `all_evidence` so that calling this once
    # per Issue doesn't re-query the database each time.
    def evidence_for(issue)
      @evidence_for_lookup ||= all_evidence.to_a
      @evidence_for_lookup.select { |e| e.issue_id == issue.id }
    end

    def create_evidence(args = {})
      content = args.fetch(:content, default_evidence_content)
      node = args.fetch(:node, default_node_parent)
      issue = args[:issue] || default_evidence_issue
      state = args.fetch(:state, @state)

      # Using node.evidence.new would result in some evidence being saved later on.
      evidence = ::Evidence.new(issue_id: issue.id, content: content, node_id: node.id, state: state)

      if evidence.valid?
        evidence = ::Evidence.find_or_create_by(issue_id: issue.id, node_id: node.id, content: content) do |e|
          e.state = state
        end
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
