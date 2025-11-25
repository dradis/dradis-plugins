
# When you call provides :upload in your Engine, this module gets included.
module Dradis::Plugins::Mappings::Base
  extend ActiveSupport::Concern

  included do
    module_parent.extend ClassMethods
  end

  module ClassMethods
    def default_mapping_fields(source)
      default_mapping(source).map do |destination_field, content|
        MappingField.new(destination_field: destination_field, content: content)
      end
    end

    def component
      meta[:name].to_s
    end

    def field_names(source:, destination: nil, field_type: 'destination')
      mappings = mappings(source: source, destination: destination)

      mapping_fields = if mappings.any?
        mappings.map(&:mapping_fields).flatten
      end

      if mapping_fields && mapping_fields.any?
        mapping_fields.pluck("#{field_type}_field").uniq
      else
        default_mapping(source).keys
      end
    end

    def default_mapping(source)
      if mapping_sources.include?(source.to_sym)
        self::Mapping::DEFAULT_MAPPING[source.to_sym]
      end
    end

    # given the params returns all matching mappings
    # will accept source and/or destination or no args
    def mappings(source: nil, destination: nil)
      mappings = Mapping.includes(:mapping_fields).where(
        component: component
      )
      mappings = mappings.where(source: source) if source
      mappings = mappings.where(destination: destination) if destination
      mappings
    end

    # returns single matching mapping given source & destination or default
    def get_mapping(source:, destination:)
      mapping = Mapping.includes(:mapping_fields).find_by(
        component: component,
        source: source,
        destination: destination
      )
    end

    def mapping_fields(source:, destination:)
      mapping = get_mapping(source: source, destination: destination)

      if mapping
        mapping.mapping_fields
      else
        default_mapping_fields(source)
      end
    end

    def mapping_sources
      self::Mapping::SOURCE_FIELDS.keys
    end

    def source_fields(source)
      if mapping_sources.include?(source.to_sym)
        self::Mapping::SOURCE_FIELDS[source.to_sym]
      end
    end
  end
end
