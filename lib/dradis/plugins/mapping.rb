
# When you call provides :upload in your Engine, this module gets included.
module Dradis::Plugins::Mapping
  extend ActiveSupport::Concern

  included do
    module_parent.extend ClassMethods
  end

  module ClassMethods
    def default_mapping(source)
      self::Mapping::DEFAULT_MAPPING[source.to_sym]
    end

    def mapping(component:, source:, destination:)
      Mapping.includes(:mapping_fields).find_by(
        component: component,
        source: source,
        destination: destination
      )
    end

    def mapping_fields(component:, source:, destination:)
      mapping = mapping(component, source, destination)
      # fetch mapping_fields through mapping or default
      if mapping && mapping.mapping_fields.any?
        mapping.mapping_fields
      else
        default_mapping(source)
      end
    end

    def mapping_sources
      self::Mapping::SOURCE_FIELDS.keys
    end

    def source_fields(source)
      self::Mapping::SOURCE_FIELDS[source.to_sym]
    end
  end
end
