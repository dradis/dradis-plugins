module Dradis
  module Plugins
    module Export
      class BaseController < Dradis::Plugins::base_export_controller_class.to_s.constantize

      end
    end
  end
end
