module Dradis
  module Plugins
    module Exportable
      extend ActiveSupport::Concern

      included do
        before_action :set_exporter, only: [:create]
        before_action :validate_scope, only: [:create]
        before_action :validate_template, only: [:create]
      end

      private

      def set_exporter
        raise NotImplementedError
      end

      def templates_dir
        @templates_dir ||= File.join(::Configuration::paths_templates_reports, @exporter)
      end

      def validate_scope
        unless Dradis::Plugins::ContentService::Base::VALID_SCOPES.include?(export_params[:scope])
          raise 'Something fishy is going on...'
        end
      end

      def validate_template
        @template_file =
          File.expand_path(File.join(templates_dir, export_params[:template]))

        unless @template_file.starts_with?(templates_dir) && File.exists?(@template_file)
          raise 'Something fishy is going on...'
        end
      end
    end
  end
end
