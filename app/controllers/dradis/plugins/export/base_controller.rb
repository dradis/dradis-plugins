module Dradis
  module Plugins
    module Export
      class BaseController < Rails.application.config.dradis.base_export_controller_class_name.to_s.constantize
        include Exportable
        include ProjectScoped
        include UsageTracking if defined?(Dradis::Pro)

        after_action :track_export, only: [:create], if: -> { defined?(Dradis::Pro) }

        protected

        def export_params
          params.permit(:project_id, :scope, :template)
        end

        private

        def set_exporter
          @exporter = "#{self.class.to_s.deconstantize}::Engine".constantize.plugin_name.to_s
        end
      end
    end
  end
end
