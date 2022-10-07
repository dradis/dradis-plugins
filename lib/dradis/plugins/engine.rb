module Dradis
  module Plugins
    class Engine < ::Rails::Engine
      isolate_namespace Dradis::Plugins

      config.dradis = ActiveSupport::OrderedOptions.new

      initializer "dradis-plugins.set_configs" do |app|
        options = app.config.dradis
        options.base_export_controller_class_name ||= 'AuthenticatedController'
        options.thor_helper_module ||= Dradis::Plugins::ThorHelper
      end

      initializer 'dradis-plugins.mount_routes' do
        Rails.application.routes.append do
          mount Dradis::Plugins::Engine => '/', as: :engine
        end
      end
    end
  end
end
