
# When you call provides :upload in your Engine, this module gets included.
module Dradis::Plugins::Mapping
  extend ActiveSupport::Concern

  included do
    module_parent.extend ClassMethods
  end

  module ClassMethods

    def component
      meta[:name].to_s
    end

    def field_names(source:, destination: nil, field_type: 'destination')
      mappings = Mapping.includes(:mapping_fields).where(component: component)
      mappings = mappings.where(source: source) if source
      mappings = mappings.where(destination: destination) if destination

      fields = mappings.pluck("mapping_fields.#{field_type}_field").uniq

      if fields.empty? && source
        default_mapping(source).keys
      else
        fields
      end
    end

    def default_mapping(source)
      self::Mapping::DEFAULT_MAPPING[source.to_sym]
    end

    def mapping(source:, destination:)
      Mapping.includes(:mapping_fields).find_by(
        component: component,
        source: source,
        destination: destination
      )
    end

    def mapping_fields(source:, destination:)
      mapping = mapping(source, destination)
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
