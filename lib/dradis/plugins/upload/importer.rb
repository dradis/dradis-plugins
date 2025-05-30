# This module contains basic Upload plugin functions to control template
# sample and field management for the Plugin Manager.
#
module Dradis
  module Plugins
    module Upload
      class Importer
        attr_accessor(
          :content_service,
          :default_user_id,
          :logger,
          :mapping_service,
          :options,
          :plugin,
          :project,
          :state,
        )

        def self.templates
          { evidence: 'evidence', issue: 'issue' }
        end

        def initialize(args={})
          @options = args

          @default_user_id = args[:default_user_id] || -1
          @logger = args.fetch(:logger, Rails.logger)
          @plugin = args[:plugin] || default_plugin
          @project = args.key?(:project_id) ? Project.find(args[:project_id]) : nil
          @state = args.fetch(:state, :draft)

          @content_service   = args.fetch(:content_service, default_content_service)
          @mapping_service   = default_mapping_service

          post_initialize(args)
        end

        def import(args={})
          raise "The import() method is not implemented in this plugin [#{self.class.name}]."
        end

        # This method can be overwriten by plugins to do initialization tasks.
        def post_initialize(args={})
        end

        private
        def default_content_service
          @content ||= Dradis::Plugins::ContentService::Base.new(
            logger: logger,
            plugin: plugin,
            project: project,
            state: state
          )
        end

        # This assumes the plugin's Importer class is directly nexted into the
        # plugin's namespace (e.g. Dradis::Plugins::Nessus::Importer)
        def default_plugin
          plugin_module   = self.class.name.deconstantize
          plugin_constant = plugin_module.constantize

          if defined?(plugin_constant::Engine)
            plugin_engine   = plugin_constant::Engine
            if Dradis::Plugins.registered?(plugin_engine)
              plugin_constant
            else
              raise "Your plugin isn't registered with the framework."
            end
          else
            raise "You need to pass a :plugin value to your Importer or define it under your plugin's root namespace."
          end
        end

        def default_mapping_service
          rtp = project.report_template_properties if project
          destination = rtp ? rtp.as_mapping_destination : nil

          Dradis::Plugins::MappingService.new(
            destination: destination,
            integration: plugin
          )
        end
      end # Importer

    end # Upload
  end # Plugins
end # Core
