# This module contains basic Export plugin functions.
#

module Dradis
  module Plugins
    module Export
      class Base
        attr_accessor :logger

        def initialize(args={})
          @logger = args.fetch(:logger, Rails.logger)

          post_initialize(args)
        end

        def export(args={})
          raise "The export() method is not implemented in this plugin [#{self.class.name}]."
        end

        # This method can be overwriten by plugins to do initialization tasks.
        def post_initialize(args={})
        end
      end # Base

    end # Export
  end # Plugins
end # Core