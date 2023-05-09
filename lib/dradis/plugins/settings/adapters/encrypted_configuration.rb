module Dradis::Plugins::Settings::Adapters
  class EncryptedConfiguration
    def delete(key)
      raise NotImplementedError
    end

    def exists?(key)
      raise NotImplementedError
    end

    def read(key)
      raise NotImplementedError
    end

    def write(key, value)
      raise NotImplementedError
    end
  end
end
