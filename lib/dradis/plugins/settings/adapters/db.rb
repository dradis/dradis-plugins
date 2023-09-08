module Dradis::Plugins::Settings::Adapters
  class Db
    def initialize(namespace)
      @namespace = namespace.to_s
    end

    def delete(key)
      Configuration.find_by(name: namespaced_key(key)).destroy
    end

    def exists?(key)
      (ActiveRecord::Base.connection rescue false) &&
        Configuration.exists?(name: namespaced_key(key))
    end

    def read(key)
      Configuration.find_by(name: namespaced_key(key))&.value
    end

    def write(key, value)
      db_setting = Configuration.find_or_create_by(name: namespaced_key(key))
      db_setting.update_attribute(:value, value)
    end

    private

    def namespaced_key(key)
      [@namespace, key.to_s.underscore].join(':')
    end
  end
end
