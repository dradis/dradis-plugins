# This module contains basic Upload plugin functions to control template
# sample and field management for the Plugin Manager.
#
module Dradis
  module Plugins
    module Upload
      class Importer
        attr_accessor :content_service, :logger, :plugin, :template_service

        def initialize(args={})
          @plugin = args.fetch(:plugin)
          @logger = args.fetch(:logger, Rails.logger)

          @content_service  = args.fetch(:content_service, default_content_service)
          @template_service = args.fetch(:template_service, default_template_service)

          content_service.logger  = logger
          content_service.plugin  = plugin
          template_service.logger = logger
          template_service.plugin = plugin

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
          @content ||= Dradis::Plugins::ContentService::Base.new
        end

        def default_template_service
          @template ||= Dradis::Plugins::TemplateService.new
        end
      end # Importer

    end # Upload
  end # Plugins
end # Core
