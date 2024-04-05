module Dradis
  module Plugins
    class MappingService
      attr_accessor :component, :destination, :integration, :source

      def initialize(args = {})
        @component = args[:component]
        @integration = args[:integration]
        @destination = args[:destination]
        @sample_dir = args[:sample_dir] || default_sample_dir
      end

      def apply_mapping(args = {})
        @source = args[:source] || source
        return unless validate_source
        data = args[:data]
        field_processor = integration::FieldProcessor.new(data: data)
        mapping_fields = args[:mapping_fields] || get_mapping_fields

        mapping_fields.map do |field|
          field_name = field.try(:destination_field) || field[0]
          field_content = process_content(
            field.try(:content) || field[1],
            field_processor
          )

          "#[#{field_name}]#\n#{field_content}"
        end&.join("\n\n")
      end

      # This returns a sample of valid entry for the Mappings Manager
      def sample
        @sample ||= {}
        if validate_source
            @sample[source] ||= begin
            sample_file = File.join(@sample_dir, "#{source}.sample")
            File.read(sample_file)
          end
        end
      end

      private

      # This method returns the default location in which integrations store their sample files
      def default_sample_dir
        @default_sample_dir ||= begin
          File.join(Configuration.paths_templates_plugins, component)
        end
      end

      def get_mapping_fields
        mapping = Mapping.includes(:mapping_fields).find_by(
          component: component,
          source: source,
          destination: destination
        )

        # fetch mapping_fields through mapping or default
        if mapping && mapping.mapping_fields.any?
          mapping.mapping_fields
        else
          integration.default_mapping(source)
        end
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

      def validate_source
        @source = source if integration.mapping_sources.include?(source.to_sym)
      end
    end
  end
end
