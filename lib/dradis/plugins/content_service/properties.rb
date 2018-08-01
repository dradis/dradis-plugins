module Dradis::Plugins::ContentService
  module Properties
    extend ActiveSupport::Concern

    def all_properties
      project.content_library.properties
    end
  end
end
