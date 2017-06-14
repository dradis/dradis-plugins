module Dradis::Plugins::ContentService
  module Properties
    extend ActiveSupport::Concern

    def all_properties
      # TODO: once Report Content is out, we need to load the properties from
      # Node.content_library and also take into account project scoping.
      Note.
        where(category_id: legacy_report_properties_category).
        limit(1).
        first.
        try(:fields) || {}
    end

    private
    def legacy_report_properties_category
      @legacy_report_properties_category ||= Category.find_by_name(Dradis::Pro::Plugins::Word::Engine.settings.category_properties)
    end
  end
end
