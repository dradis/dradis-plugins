module Dradis
  module Plugins
    # Helper methods for plugin Thor tasks
    module ThorHelper
      attr_accessor :task_options, :logger

      def detect_and_set_project_scope
        task_options[:project_id] = Project.new.id
      end

      def task_options
        @task_options ||= { logger: logger, state: detect_state }
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

      def detect_state
        if options.state && Upload::Importer::VALID_STATES.include?(options.state)
          options.state.to_sym
        else
          :draft
        end
      end
    end
  end
end
