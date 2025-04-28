module Dradis
  module Plugins
    # Helper methods for plugin Thor tasks
    module ThorHelper
      attr_accessor :task_options, :logger

      def detect_and_set_project_scope
        task_options[:project_id] = Project.new.id
      end

      def task_options
        @task_options ||= { logger: logger, state: :draft }
      end

      def logger
        @logger ||= default_logger
      end


      private
      def default_logger
        STDOUT.sync   = true
        logger        = Logger.new(STDOUT)
        logger.level  = Logger::DEBUG
        logger
      end
    end
  end
end
