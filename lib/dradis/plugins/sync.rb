module Dradis
  module Plugins
    module Sync
      extend ActiveSupport::Concern

      module ClassMethods
        # Returns information about the settings that must be present in order
        # for the plugin to work. Override in each plugin. Must return an array
        # of hashes; each hash must at minimum have a key caleld 'name'
        #
        # Use Symbol keys for the hash.
        def settings_template # TODO can anyone think of a better name?
          raise(
            NotImplementedError,
            "plugin #{name} must define .settings_template"
          )
        end

        # @param key [Symbol]
        def has_setting?(key)
          settings_template.any? { |s| s[:key] == key }
        end

        def human_name
          name.gsub(/^Dradis::Plugins::/, '').gsub(/::Engine$/, '')
        end
      end
    end
  end
end
