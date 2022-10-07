module Dradis::Plugins
  class Settings
    attr_reader :namespace

    def initialize(namespace)
      @namespace = namespace
      @dirty_options ||= {}
      @default_options ||= HashWithIndifferentAccess.new
    end

    def respond_to?(name)
      super || @dirty_options.key?(name.to_sym)
    end

    def all
      @default_options.map do |key, value|
        {
          name: key.to_sym,
          value: value = dirty_or_db_setting_or_default(key.to_sym),
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
        Configuration.where(name: namespaced_key(key)).each(&:destroy)
      end
    end

    def is_default?(key, value)
      value.to_s == @default_options[key.to_sym].to_s
    end

    def engine_enable
      enable = db_setting(:enable)
      enable ? (enable == '1') : nil
    end

    def toggle_engine(value)
      write_to_db(:enable, value)
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

    def write_to_db(key, value)
      db_setting = Configuration.find_or_create_by(name: namespaced_key(key))
      db_setting.update_attribute(:value, value)
    end


    def db_setting(key)
      Configuration.where(name: namespaced_key(key)).first.value rescue nil
    end

    # This method looks up in the configuration repository DB to see if the
    # user has provided a value for the given setting. If not, the default
    # value is returned.
    def dirty_or_db_setting_or_default(key)
      if @dirty_options.key?(key)
        @dirty_options[key]
      elsif Configuration.exists?(name: namespaced_key(key))
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
