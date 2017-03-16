# This module contains basic Export plugin functions.
#

module Dradis
  module Plugins
    module Export
      class Base
        attr_accessor :content_service, :logger, :options, :plugin, :project

        def initialize(args={})
          # Save everything just in case the implementing class needs any of it.
          @options = args

          # Can't use :fetch for :plugin or :default_plugin gets evaluated
          @logger  = args.fetch(:logger, Rails.logger)
          @plugin  = args[:plugin] || default_plugin
          @project = args.key?(:project_id) ? Project.find(args[:project_id]) : nil

          @content_service = args.fetch(:content_service, default_content_service)

          post_initialize(args)
        end

        def export(args={})
          raise "The export() method is not implemented in this plugin [#{self.class.name}]."
        end

        # This method can be overwriten by plugins to do initialization tasks.
        def post_initialize(args={})
        end

        private
        def default_content_service
          @content ||= Dradis::Plugins::ContentService::Base.new(
            logger: logger,
            plugin: plugin,
            project: project
          )
        end

        # This assumes the plugin's Exporter class is directly nexted into the
        # plugin's namespace (e.g. Dradis::Plugins::HtmlExport::Exporter)
        def default_plugin
          plugin_module   = self.class.name.deconstantize
          plugin_constant = plugin_module.constantize
          plugin_engine   = plugin_constant::Engine
          if Dradis::Plugins.registered?(plugin_engine)
            plugin_constant
          else
            raise "You need to pass a :plugin value to your Exporter or define it under your plugin's root namespace."
          end
        end

      end # Base
    end # Export
  end # Plugins
end # Core
