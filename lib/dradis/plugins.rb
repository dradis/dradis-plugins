module Dradis
  module Plugins
    class << self
      @@engines = []
      @@outdated = []

      # Returns an array of modules representing currently registered Dradis Plugins / engines
      #
      # Example:
      #   Dradis::Core::Plugins.list  =>  [Dradis::Core, Dradis::Frontend]
      def list
        @@engines
      end

      def outdated
        @@outdated
      end

      # Register a plugin with the framework
      #
      # Example:
      #   Dradis::Core::Plugins.register(Dradis::Core)
      def register(engine)
        # byebug if engine.to_s.include?('Open')
        return if registered?(engine)

        if valid?(engine.railtie_namespace)
          @@engines << engine
        else
          @@outdated << engine
        end
      end

      # Returns true if a plugin is currently registered with the framework
      #
      # Example:
      #   Dradis::Core::Plugins.registered?(Dradis::Core)
      def registered?(engine)
        @@engines.include?(engine) || @@outdated.include?(engine)
      end

      # Unregister a plugin from the framework
      #
      # Example:
      #   Dradis::Core::Plugins.unregister(Dradis::Core)
      def unregister(engine)
        @@engines.delete(engine)
      end

      # Filters the list of plugins and only returns those that provide the
      # requested feature.
      def with_feature(feature)
        @@engines.select do |plugin|
          # engine = "#{plugin}::Engine".constantize
          plugin.provides?(feature)
        end
      end

      private

      # Use this to ensure the Extension conforms with some expected interface
      def valid?(plugin)
        # Version defined
        unless plugin.respond_to?(:gem_version)
          return false
        end

        # Engine version matches framework's
        return plugin.gem_version >= Dradis::Plugins.gem_version
      end
    end
  end
end


require 'dradis/plugins/engine'
require 'dradis/plugins/version'

require 'dradis/plugins/content_service/base'
require 'dradis/plugins/template_service'

require 'dradis/plugins/base'
require 'dradis/plugins/export'
require 'dradis/plugins/import'
require 'dradis/plugins/upload'

# Common functionality
require 'dradis/plugins/configurable'
require 'dradis/plugins/settings'
require 'dradis/plugins/templates'
require 'dradis/plugins/thor'
require 'dradis/plugins/thor_helper'
