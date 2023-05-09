module Dradis::Plugins::Settings::Adapters
  class Db
    def delete(key)
      Configuration.find_by(name: key).destroy
    end

    def exists?(key)
      Configuration.exists?(name: key)
    end

    def read(key)
      Configuration.find_by(name: key).value rescue nil
    end

    def write(key, value)
      db_setting = Configuration.find_or_create_by(name: key)
      db_setting.update_attribute(:value, value)
    end
  end
end
