module Dradis
  module Plugins
    # Helper methods for plugin Thor tasks
    module ThorHelper
      # A default logger to STDOUT that doesn't close, even if #close is called
      class DefaultLogger < Logger
        def initialize
          STDOUT.sync = true
          super(STDOUT)
          self.level = Logger::DEBUG
        end

        def close; end
      end

      attr_accessor :task_options, :logger

      def detect_and_set_project_scope
        ;
      end

      def task_options
        @task_options ||= { logger: logger }
      end

      def logger
        @logger ||= DefaultLogger.new
      end
    end
  end
end
