module Dradis
  module Plugins
    class << self
      @@extensions = []

      # Returns an array of modules representing currently registered Dradis Plugins / engines
      #
      # Example:
      #   Dradis::Core::Plugins.list  =>  [Dradis::Core, Dradis::Frontend]
      def list
        @@extensions
      end

      # Returns an array of modules representing currently enabled engines
      def enabled_list
        @@enabled_list ||= @@extensions.select(&:enabled?)
      end

      def clear_enabled_list
        @@enabled_list = nil
      end

      # Filters the list of plugins and only returns those that provide the
      # requested feature and enabled
      def with_feature(feature)
        enabled_list.select do |plugin|
          # engine = "#{plugin}::Engine".constantize
          plugin.provides?(feature)
        end
      end

      # Register a plugin with the framework
      #
      # Example:
      #   Dradis::Core::Plugins.register(Dradis::Core)
      def register(const)
        return if registered?(const)

        validate_plugin!(const)

        @@extensions << const
      end

      # Unregister a plugin from the framework
      #
      # Example:
      #   Dradis::Core::Plugins.unregister(Dradis::Core)
      def unregister(const)
        @@extensions.delete(const)
      end

      # Returns true if a plugin is currently registered with the framework
      #
      # Example:
      #   Dradis::Core::Plugins.registered?(Dradis::Core)
      def registered?(const)
        @@extensions.include?(const)
      end

      def upload_integration_names_and_modules
        with_feature(:upload).each_with_object({}) do |integration, integrations_hash|
          integration_name = integration.plugin_name.to_s
          integration_module = integration.module_parent

          integrations_hash[integration_name] = integration_module
        end
      end

      private

      # Use this to ensure the Extension conforms with some expected interface
      def validate_plugin!(const)
        # unless const.respond_to?(:root) && const.root.is_a?(Pathname)
        #   raise InvalidEngineError, "Engine must define a root accessor that returns a pathname to its root"
        # end
      end
    end
  end
end


require 'dradis/plugins/engine'
require 'dradis/plugins/version'

require 'dradis/plugins/content_service/base'
require 'dradis/plugins/mapping_service'

require 'dradis/plugins/base'
require 'dradis/plugins/export'
require 'dradis/plugins/import'
require 'dradis/plugins/mapping'
require 'dradis/plugins/upload'

# Common functionality
require 'dradis/plugins/configurable'
require 'dradis/plugins/settings'
require 'dradis/plugins/settings/adapters/db'
require 'dradis/plugins/settings/adapters/encrypted_configuration'
require 'dradis/plugins/templates'
require 'dradis/plugins/thor'
require 'dradis/plugins/thor_helper'
