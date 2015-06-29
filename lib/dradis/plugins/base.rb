module Dradis
  module Plugins
    module Base
      extend ActiveSupport::Concern

      included do
        # mattr_accessor :plugin_name

        @features = []
        @name = 'Use plugin_info(args) with :name to provide a name for this plugin.'
        Plugins::register(self)

        # Extend the engine with other functionality
        include Dradis::Plugins::Configurable
        include Dradis::Plugins::Templates
        include Dradis::Plugins::Thor
      end

      module ClassMethods
        def description(new_description)
          @description = new_description
        end

        def plugin_description
          @description ||= "This plugin doesn't provide a :description"
        end

        def plugin_name
          @plugin_name ||= self.name.split('::')[2].underscore.to_sym
        end

        def provides(*list)
          @features = list
          if list.include?(:upload)
            include Dradis::Plugins::Upload::Base
          end
        end

        def provides?(feature)
          @features.include?(feature)
        end
      end
    end
  end
end
