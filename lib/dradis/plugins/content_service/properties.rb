module Dradis::Plugins::ContentService
  module Properties
    extend ActiveSupport::Concern

    def all_properties
      Node.content_library.properties
    end
  end
end
