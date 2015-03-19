module Dradis::Plugins
  class Settings
    attr_reader :namespace

    def initialize(namespace)
      @namespace = namespace
      @dirty_options ||= {}
      @default_options ||= {}
    end

    def respond_to?(name)
      super || @dirty_options.key?(name.to_sym)
    end

    def all
      @default_options.map do |key, value|
        {
          name: key,
          value: value = dirty_or_db_setting_or_default(key),
          default: is_default?(key, value)
        }
      end.sort_by{ |o| o[:name] }
    end

    def save
      @dirty_options.reject{ |k, v| v.present? && v == db_setting(k) }.each{ |k, v| write_to_db(k, v) }
    end

    def update_settings(opts = {})
      opts.select{ |k, v| @default_options.key?(k) }.each do |k, v|
        @dirty_options[k.to_sym] = v
      end
      save
    end

    def reset_defaults!
      @dirty_options = {}
      @default_options.each do |key, value|
        configuration_class.where(name: namespaced_key(key)).each(&:destroy)
      end
    end

    def is_default?(key, value)
      value.to_s == @default_options[key.to_sym].to_s
    end

    private

    # ---------------------------------------------------- Method missing magic
    def method_missing(name, *args, &blk)
      if name.to_s =~ /^default_(.*)=$/
        @default_options[$1.to_sym] = args.first
      elsif name.to_s =~ /=$/
        @dirty_options[$`.to_sym] = args.first
      elsif @default_options.key?(name)
        dirty_or_db_setting_or_default(name)
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

    def write_to_db(key, value)
      db_setting = configuration_class.find_or_create_by_name(namespaced_key(key))
      db_setting.update_attribute(:value, value)
    end


    def db_setting(key)
      configuration_class.where(name: namespaced_key(key)).first.value rescue nil
    end

    # This method looks up in the configuration repository DB to see if the
    # user has provided a value for the given setting. If not, the default
    # value is returned.
    def dirty_or_db_setting_or_default(key)
      if @dirty_options.key?(key)
        @dirty_options[key]
      elsif configuration_class.exists?(name: namespaced_key(key))
        db_setting(key)
      else
        @default_options[key]
      end
    end

    # Builds namespaced key
    def namespaced_key(key)
      [self.namespace.to_s, key.to_s.underscore].join(":")
    end
  end
end
