module Dradis
  module Plugins
    class Engine < ::Rails::Engine
      isolate_namespace Dradis::Plugins

      config.dradis = ActiveSupport::OrderedOptions.new

      initializer "dradis-plugins.set_configs" do |app|
        options = app.config.dradis
        options.base_export_controller_class_name ||= 'ProjectScopedController'
        options.thor_helper_module ||= Dradis::Plugins::ThorHelper
      end
    end
  end
end
