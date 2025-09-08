module Dradis::Plugins::Settings::Adapters
  class Db
    def initialize(namespace)
      @namespace = namespace.to_s
    end

    def delete(key)
      Configuration.find_by(name: namespaced_key(key)).destroy
    end

    def exists?(key)
      db_ready? && Configuration.exists?(name: namespaced_key(key))
    end

    def read(key)
      db_ready? && Configuration.find_by(name: namespaced_key(key))&.value
    end

    def write(key, value)
      return unless db_ready?
      db_setting = Configuration.find_or_create_by(name: namespaced_key(key))
      db_setting.update_attribute(:value, value)
    end

    private

    def namespaced_key(key)
      [@namespace, key.to_s.underscore].join(':')
    end

    def db_ready?
      (ActiveRecord::Base.connection.verify! rescue false) && Configuration.table_exists?
    end
  end
end
