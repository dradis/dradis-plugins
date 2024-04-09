
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
      mapping_fields = mapping_fields(source: source, destination: destination)

      return mapping_fields.keys if mapping_fields.class == Hash

      mapping_fields.pluck("#{field_type}_field").uniq
    end

    def default_mapping(source)
      self::Mapping::DEFAULT_MAPPING[source.to_sym]
    end

    def mappings(source:, destination: nil)
      mappings = Mapping.includes(:mapping_fields).where(
        component: component,
        source: source,
      )
      mappings = mappings.where(destination: destination) if destination

      if mappings.any?
        mappings
      else
        default_mapping(source)
      end
    end

    def mapping_fields(source:, destination: nil)
      mappings = mappings(source: source, destination: destination)

      return mappings if mappings.class == Hash

      fields = mappings.map(&:mapping_fields).flatten

      if fields.any?
        fields
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
