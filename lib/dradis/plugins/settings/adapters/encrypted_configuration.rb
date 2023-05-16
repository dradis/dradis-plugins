module Dradis::Plugins::Settings::Adapters
  class EncryptedConfiguration
    attr_writer :config_path

    def initialize(namespace)
      @namespace = namespace
    end

    def delete(key)
      if exists?(key)
        configuration.config[@namespace].delete(key)
        configuration.write(configuration.config.to_yaml)
      end
    end

    def exists?(key)
      !!configuration.config[@namespace]&.key?(key)
    end

    def read(key)
      configuration.config[@namespace].fetch(key, nil)
    end

    def write(key, value)
      configuration.config[@namespace] ||= {}
      configuration.config[@namespace][key] = value
      configuration.write(configuration.config.to_yaml)
    end

    def key_path=(string_or_pathname)
      @key_path = Pathname.new(string_or_pathname)
    end

    private
    def config_path
      @config_path ||= Rails.root.join('config', 'shared', 'dradis-plugins.yml.enc')
    end

    def configuration
      @configuration ||= begin
          create_key unless key_path.exist?

          ActiveSupport::EncryptedConfiguration.new(
            config_path: config_path, key_path: key_path,
            env_key: 'RAILS_MASTER_KEY', raise_if_missing_key: true
          )
        end
    end

    def create_key
      File.write(key_path, ActiveSupport::EncryptedConfiguration.generate_key)
    end

    def key_path
      @key_path ||= Rails.root.join('config', 'shared', 'dradis-plugins.key')
    end
  end
end
