module Dradis::Plugins
  class Settings
    attr_reader :namespace

    def initialize(namespace)
      @namespace = namespace
      @@options ||= {}
    end

    def respond_to?(name)
      super || @@options.key?(name.to_sym)
    end

    private

    # ---------------------------------------------------- Method missing magic
    def method_missing(name, *args, &blk)
      if name.to_s =~ /=$/
        @@options[$`.to_sym] = args.first
      elsif @@options.key?(name)
        db_setting_or_default(name)
      else
        super
      end
    end
    # --------------------------------------------------- /Method missing magic

    # This allows us to use the same code in Community and Pro and overwrite
    # the name of the class in an initializer.
    def configuration_class
      @klass ||= Dradis::Plugins::configuration_class.to_s.constantize
    end

    # This method looks up in the configuration repository DB to see if the
    # user has provided a value for the given setting. If not, the default
    # value is returned.
    def db_setting_or_default(key)
      namespaced_key = [self.namespace.to_s, key.to_s.underscore].join(":")

      if configuration_class.exists?(name: namespaced_key)
        configuration_class.where(name: namespaced_key).first.try(:value)
      else
        @@options[name]
      end
    end
  end
end