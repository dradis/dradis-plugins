module Dradis
  module Plugins
    module Import
      module Filters

        class Base
          def self.query(args={})
            instance = self.new
            instance.query(args)
          end
        end

      end
    end
  end
end