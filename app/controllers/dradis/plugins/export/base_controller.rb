module Dradis
  module Plugins
    module Export
      class BaseController < Rails.application.config.dradis.base_export_controller_class_name.to_s.constantize
        before_action :validate_scope

        protected

        def export_params
          params.permit(:project_id, :scope, :template)
        end

        def validate_scope
          unless Dradis::Plugins::ContentService::Base::VALID_SCOPES.include?(params[:scope])
            raise 'Something fishy is going on...'
          end
        end
      end
    end
  end
end
