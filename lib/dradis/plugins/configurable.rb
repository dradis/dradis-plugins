module Dradis::Plugins
  module Configurable
    extend ActiveSupport::Concern

    module ClassMethods
      delegate :settings, to: :instance

      def settings_namespace
        @settings_namespace || plugin_name
      end

      def addon_settings(namespace = nil, &block)
        @settings_namespace = namespace if namespace
        yield self if block_given?
      end

      def instance
        @instance ||= new
      end
    end

    def settings
      @settings ||= Dradis::Plugins::Settings.new(self.class.settings_namespace)
    end
  end
end
