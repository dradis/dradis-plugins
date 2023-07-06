module Dradis
  module Plugins
    module Export
      class BaseController < Rails.application.config.dradis.base_export_controller_class_name.to_s.constantize
        include UsageTracking if defined?(Dradis::Pro)

        before_action :validate_scope
        before_action :validate_template
        after_action :track_export, if: -> { defined?(Dradis::Pro) }

        protected

        def export_params
          params.permit(:project_id, :scope, :template)
        end

        def validate_template
          @template_file =
            File.expand_path(File.join(templates_dir, export_params[:template]))

          unless @template_file.starts_with?(templates_dir) && File.exists?(@template_file)
            raise 'Something fishy is going on...'
          end
        end

        def validate_scope
          unless Dradis::Plugins::ContentService::Base::VALID_SCOPES.include?(export_params[:scope])
            raise 'Something fishy is going on...'
          end
        end

        private

        def engine_name
          "#{self.class.to_s.deconstantize}::Engine".constantize.plugin_name.to_s
        end

        def templates_dir
          @templates_dir ||= File.join(::Configuration::paths_templates_reports, engine_name)
        end

        def track_export
          project = Project.includes(:evidence, :nodes).find(current_project.id)
          track_usage('report.exported', {
            exporter: engine_name,
            issue_count: project.issues.size,
            evidence_count: project.evidence.size,
            node_count: project.nodes.in_tree.size
          })
        end
      end
    end
  end
end
