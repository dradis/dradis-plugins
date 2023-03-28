module Dradis
  module Plugins
    module Export
      class BaseController < Rails.application.config.dradis.base_export_controller_class_name.to_s.constantize
        before_action :validate_scope

        protected

        # Protected: allows export plugins to access the options sent from the
        # framework via the session object (see Export#create).
        #
        # Returns a Hash with indifferent access.
        def export_options
          @export_options ||= session[:export_manager].with_indifferent_access
        end

        def validate_scope
          @scope = params[:scope]

          unless Dradis::Plugins::ContentService::Base::VALID_SCOPES.include?(@scope)
            raise 'Something fishy is going on...'
          end
        end
      end
    end
  end
end
