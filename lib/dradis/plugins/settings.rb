module Dradis::Plugins
  class Settings
    attr_reader :namespace

    def initialize(namespace, adapter: :db)
      @namespace = namespace
      @dirty_options ||= {}
      @default_options ||= { enabled: true }.with_indifferent_access
      assign_adapter(adapter)
    end

    def respond_to?(name)
      super || @dirty_options.key?(name.to_sym)
    end

    def all
      @default_options.except(:enabled).map do |key, value|
        {
          name: key.to_sym,
          value: value = dirty_or_stored_or_default(key.to_sym),
          default: is_default?(key, value)
        }
      end.sort_by{ |o| o[:name] }
    end

    def save
      @dirty_options.reject do |k, v|
        v.present? && v == read(namespaced_key(k))
      end.each do |k, v|
        write(namespaced_key(k), v)
      end
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
        delete(namespaced_key(key)) if exists?(namespaced_key(key))
      end
    end

    def is_default?(key, value)
      value.to_s == @default_options[key.to_sym].to_s
    end

    private
    attr_reader :adapter
    delegate :delete, :exists?, :read, :write, to: :adapter

    # ---------------------------------------------------- Method missing magic
    def method_missing(name, *args, &blk)
      if name.to_s =~ /^default_(.*)=$/
        @default_options[$1.to_sym] = args.first
      elsif name.to_s =~ /=$/
        @dirty_options[$`.to_sym] = args.first
      elsif @default_options.key?(name)
        dirty_or_stored_or_default(name)
      else
        super
      end
    end
    # --------------------------------------------------- /Method missing magic

    def assign_adapter(name)
      adapters = { db: Adapters::Db, encrypted_configuration: Adapters::EncryptedConfiguration }
      if adapters.key?(name)
        @adapter = adapters[name].new
      else
        raise ArgumentError
      end
    end

    # This method looks up in the configuration repository DB to see if the
    # user has provided a value for the given setting. If not, the default
    # value is returned.
    def dirty_or_stored_or_default(key)
      if @dirty_options.key?(key)
        @dirty_options[key]
      elsif exists?(namespaced_key(key))
        read(namespaced_key(key))
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
