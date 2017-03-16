module Dradis::Plugins::ContentService
  module Categories
    extend ActiveSupport::Concern

    def report_category
      Category.report
    end
  end
end
