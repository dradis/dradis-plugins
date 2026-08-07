module Dradis
  module Plugins
    class MappingService
      attr_accessor :component, :destination, :integration, :source

      def initialize(destination: nil, integration:)
        @destination = destination
        @integration = integration
        @component = @integration.meta[:name].to_s
      end

      def apply_mapping(data:, source:, mapping_fields: nil)
        @source = source
        return unless valid_source?

        field_processor = integration::FieldProcessor.new(data: data)
        mapping_fields = mapping_fields || get_mapping_fields

        mapping_fields.map do |field|
          field_name = field.destination_field
          field_content = process_content(
            field.content,
            field_processor
          )

          "#[#{field_name}]#\n#{field_content}"
        end&.join("\n\n")
      end

      # This returns a sample of valid entry for the Mappings Manager
      def sample
        @sample ||= {}
        @sample[source] ||= integration.sample(source) if valid_source?
      end

      private

      def source_fields
        @source_fields ||= {}
        @source_fields[source] ||= integration.source_fields(source)
      end

      def get_mapping_fields
        # returns the mapping fields for the found mapping,
        # or the default mapping_fields
        integration.mapping_fields(
          source: source,
          destination: destination
        )
      end

      def process_content(content, field_processor)
        content.gsub(/{{\s?#{component}\[(\S*?)\]\s?}}/) do |field|
          name = field.split(/\[|\]/)[1]

          if source_fields.include?(name)
            field_processor.value(field: name)
          else
            "Field [#{field}] not recognized by the integration"
          end
        end
      end

      def valid_source?
        valid_sources ||= integration.mapping_sources
        @source = source if valid_sources.include?(source.to_sym)
      end
    end
  end
end
