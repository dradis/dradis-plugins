
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

    def mapping_sources
      self::Mapping::SOURCE_FIELDS.keys
    end

    def source_fields(source)
      self::Mapping::SOURCE_FIELDS[source.to_sym]
    end
  end
end
