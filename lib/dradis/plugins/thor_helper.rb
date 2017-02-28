module Dradis
  module Plugins
    # Helper methods for plugin Thor tasks
    module ThorHelper
      def content_service_for(plugin)
        Dradis::Plugins::ContentService::Base.new(plugin: plugin)
      end

      def detect_and_set_project_scope
        ;
      end
    end
  end
end