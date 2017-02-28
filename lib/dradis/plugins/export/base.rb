# This module contains basic Export plugin functions.
#

module Dradis
  module Plugins
    module Export
      class Base
        attr_accessor :content_service, :logger

        def initialize(args={})
          @plugin = args.fetch(:plugin)
          @logger = args.fetch(:logger, Rails.logger)

          @content_service = args[:content_service] || default_content_service

          content_service.logger = logger
          content_service.plugin = plugin

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
          @content ||= Dradis::Plugins::ContentService::Base.new
        end

      end # Base
    end # Export
  end # Plugins
end # Core
