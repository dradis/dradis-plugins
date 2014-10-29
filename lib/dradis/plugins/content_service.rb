module Dradis
  module Plugins
    class ContentService
      attr_accessor :logger, :plugin

      # ----------------------------------------------------------- Initializer
      #

      def initialize(args={})
        @plugin = args[:plugin]
      end


      # ------------------------------------------------------ Query operations

      def all_issues
        class_for(:issue).where(category_id: default_issue_category.id)
      end

      # Create a hash with all issues where the keys correspond to the field passed
      # as an argument.
      #
      # This is use by the plugins to check whether a given issue is already in
      # the project.
      # def all_issues_by_field(field)
      #   # we don't memoize it because we want it to reflect recently added Issues
      #   klass = class_for(:issue)
      #
      #   issues_map = klass.where(category_id: default_issue_category.id).map do |issue|
      #     [issue.fields[field], issue]
      #   end
      #   Hash[issues_map]
      # end

      # Accesing the library by primary sorting key. Raise an exception unless
      # the issue library cache has been initialized.
      def issue_cache
        @issue_cache ||= begin
          klass = class_for(:issue)

          issues_map = klass.where(category_id: default_issue_category.id).map do |issue|
            cache_key = [
              issue.fields['plugin'],
              issue.fields['plugin_id']
            ].join('-')

            [cache_key, issue]
          end
          Hash[issues_map]
        end
      end

      # def all_notes
      #
      # end

      # ----------------------------------------------------- Create operations
      #

      def create_node(args={})
        label   = args[:label] || "create_node() invoked by #{plugin} without a :label parameter"
        parent  = args[:parent] || default_parent_node
        type_id = begin
          tmp_type = args[:type].to_s.upcase
          class_for(:node)::Types::const_defined?(tmp_type) ? "#{class_for(:node)::Types}::#{tmp_type}".constantize : default_node_type
        end

        # FIXME: how ugly is this?
        if Rails::VERSION::MAJOR == 3
          parent.children.find_or_create_by_label_and_type_id(label, type_id)
        else
          parent.children.find_or_create_by(label: label, type_id: type_id)
        end
      end

      def create_note(args={})
        node = args[:node] || default_parent_node
        text = args[:text] || "create_note() invoked by #{plugin} without a :text parameter"

        node.notes.create text: text, category: default_note_category, author: default_author
      end

      def create_issue(args={})
        text = args[:text] || "create_issue() invoked by #{plugin} without a :text parameter"
        id   = args[:id]   || "create_issue() invoked by #{plugin} without an :id parameter"

        # Bail if we already have this issue in the cache
        uuid      = [plugin::Engine::plugin_name, id]
        cache_key = uuid.join('-')

        return issue_cache[cache_key] if issue_cache.key?(cache_key)

        # we inject the source Plugin and unique ID into the issue's text
        text << "\n\n#[plugin]#\n#{uuid[0]}\n"
        text << "\n\n#[plugin_id]#\n#{uuid[1]}\n"

        issue = class_for(:issue).create(text: text) do |i|
          i.author   = default_author
          i.node     = issuelib
          i.category = default_issue_category
        end

        issue_cache[cache_key] = issue
      end

      def create_evidence(args={})
        content = args[:content] || "create_evidence() invoked by #{plugin} without a :content parameter"
        node    = args[:node] || default_parent_node
        issue   = args[:issue] || create_issue(text: "#[Title]#\nAuto-generated issue.\n\n#[Description]#\ncreate_evidence() invoked by #{plugin} without an :issue parameter")

        node.evidence.create(issue_id: issue.id, content: content)
      end


      private

      def class_for(model)
        "Dradis::Core::#{model.to_s.capitalize}".constantize
      end


      def default_author
        @default_author ||= "#{plugin::Engine.plugin_name.to_s.humanize} upload plugin"
      end

      def default_issue_category
        @default_issue_category ||= class_for(:category).issue
      end

      def default_node_type
        @default_node_type ||= class_for(:node)::Types::DEFAULT
      end

      def default_note_category
        @default_note_category ||= class_for(:category).default
      end

      def default_parent_node
        @default_parent_node ||= class_for(:node).find_or_create_by(label: 'plugin.output')
      end

      def issuelib
        @issuelib ||= class_for(:node).issue_library
      end
    end
  end
end
