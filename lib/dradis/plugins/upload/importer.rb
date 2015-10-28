# This module contains basic Upload plugin functions to control template
# sample and field management for the Plugin Manager.
#
module Dradis
  module Plugins
    module Upload
      class Importer
        attr_accessor :content_service, :logger, :template_service

        def initialize(args={})
          @logger = args.fetch(:logger, Rails.logger)

          @content_service = args[:content_service] || default_content_service
          @template_service = args[:template_service] || default_template_service

          content_service.logger = logger
          template_service.logger = logger

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
          @content ||= Dradis::Plugins::ContentService.new
        end

        def default_template_service
          @template ||= Dradis::Plugins::TemplateService.new
        end
      end # Importer

    end # Upload
  end # Plugins
end # Core
