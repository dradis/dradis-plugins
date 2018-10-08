module Dradis::Plugins::ContentService
  module Evidence
    extend ActiveSupport::Concern

    def create_evidence(args={})
      content = args.fetch(:content, default_evidence_content)
      node    = args.fetch(:node, default_node_parent)
      issue   = args[:issue] || default_evidence_issue

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

    def create_many_evidence(evidence)
      evidence.each do |evidence|
        evidence[:content] = default_evidence_content if evidence[:content].blank?

        evidence[:node_label] = default_node_label if evidence[:node_label].blank?
        evidence[:node_id] = project.nodes.find_by_label(evidence[:node_label]).id

        uuid      = [plugin::Engine::plugin_name, evidence[:issue][:id]]
        cache_key = uuid.join('-')
        issue = issue_cache[cache_key]
        evidence[:issue_id] =
          if issue.is_a?(Issue) # FIXME: move this to rules engine ?
            issue.id
          else
            issue.to_issue.id
          end

        # TODO: validate content length
      end

      return false if evidence.empty?

      time = Time.now.strftime('%Y-%m-%d %H:%M:%S')
      values = evidence.map{ |e| "(#{ActiveRecord::Base.connection.quote(e[:content])}, '#{time}', #{e[:issue_id]}, #{e[:node_id]}, '#{time}')" }.join(',')
      sql = "INSERT INTO evidence (content, created_at, issue_id, node_id, updated_at) VALUES #{values}"

      ActiveRecord::Base.connection.execute(sql)
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
