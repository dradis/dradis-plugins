module Dradis::Plugins::ContentService
  module Nodes
    extend ActiveSupport::Concern

    def reporting_nodes
      nodes = []

      nodes |= nodes_from_evidence
      nodes |= nodes_from_properties

      # Note that the below sorting would the non-IP nodes first, then the IP
      # nodes, and will sort them by each octet.
      #
      # See:
      #  http://stackoverflow.com/questions/13996033/sorting-an-array-in-ruby-special-case
      #  http://tech.maynurd.com/archives/124
      nodes.sort_by! { |node| node.label.split('.').map(&:to_i) }
    end

    def create_node(args={})
      label  = args[:label]  || default_node_label
      parent = args[:parent] || default_node_parent

      type_id = begin
        if args[:type]
          tmp_type = args[:type].to_s.upcase
          if Node::Types::const_defined?(tmp_type)
            "Node::Types::#{tmp_type}".constantize
          else
            default_node_type
          end
        else
          default_node_type
        end
      end

      parent.children.find_or_create_by(label: label, type_id: type_id)
    end

    private

    def default_node_label
      "create_node() invoked by #{plugin} without a :label parameter"
    end

    def default_node_parent
      @default_parent_node ||= Node.plugin_parent_node
    end

    def default_node_type
      @default_node_type ||= Node::Types::DEFAULT
    end


    # Private: this method returns a list of nodes associated with Evidence
    # instances. When a node is affected by multiple issues, or multiple pieces
    # of evidence, we just want a single reference to it.
    #
    # Returns and Array with a unique collection of Nodes.
    def nodes_from_evidence
      all_issues.
        includes(:evidence, evidence: :node).
        collect(&:evidence).
        # Each Issue can have 0, 1 or more Evidence
        map { |evidence_collection| evidence_collection.collect(&:node) }.
        flatten.
        uniq
    end

    # Private: this method returns a list of nodes in the project that have some
    # properties associated with them. Typically properties are used for HOST
    # type nodes, and even if they have no issues / evidence associated, we want
    # to include them in the report.
    #
    # Returns and Array with a unique collection of Nodes.
    def nodes_from_properties
      Node.user_nodes.where("type_id <> #{Node::Types::CONTENTLIB} AND properties IS NOT NULL AND properties != '{}'")
    end
  end
end
