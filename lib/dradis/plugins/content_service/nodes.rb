module Dradis::Plugins::ContentService
  module Nodes
    extend ActiveSupport::Concern

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
  end
end
