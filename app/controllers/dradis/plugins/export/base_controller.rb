module Dradis
  module Plugins
    module Export
      class BaseController < Rails.application.config.dradis.base_export_controller_class_name.to_s.constantize
        include Exportable
        include ProjectScoped
        include UsageTracking if defined?(Dradis::Pro)

        after_action :track_export, if: -> { defined?(Dradis::Pro) }, only: [:create]

        protected

        def export_params
          params.permit(:project_id, :scope, :template)
        end

        private

        def set_exporter
          @exporter = "#{self.class.to_s.deconstantize}::Engine".constantize.plugin_name.to_s
        end

        def track_export
          project = Project.includes(:evidence, :nodes).find(current_project.id)
          track_usage('report.exported', {
            exporter: @exporter,
            issue_count: project.issues.size,
            evidence_count: project.evidence.size,
            node_count: project.nodes.in_tree.size
          })
        end
      end
    end
  end
end
