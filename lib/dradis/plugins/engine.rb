module Dradis
  module Plugins
    class Engine < ::Rails::Engine
      isolate_namespace Dradis::Plugins

      # initializer 'frontend.append_migrations' do |app|
      #   unless app.root.to_s == root.to_s
      #     config.paths["db/migrate"].expanded.each do |path|
      #       app.config.paths["db/migrate"].push(path)
      #     end
      #   end
      # end

      # initializer 'frontend.asset_precompile_paths' do |app|
      #   app.config.assets.precompile += ["dradis/frontend/manifests/*"]
      # end

      Dradis::Plugins::setup do |config|
        config.base_export_controller_class = 'ProjectScopedController'
        config.configuration_class          = '::Configuration'
        config.thor_helper_module           = 'Dradis::Plugins::ThorHelper'
      end
    end
  end
end
