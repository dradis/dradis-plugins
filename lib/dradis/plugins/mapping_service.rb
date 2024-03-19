module Dradis
  module Plugins
    class MappingService
      attr_accessor :integration, :rtp_id, :source

      def initialize(args = {})
        @integration   = args.fetch(:integration)
        @rtp_id        = args.fetch(:rtp_id, nil)
        @templates_dir = args.fetch(:templates_dir, default_templates_dir)
      end

      def apply_mapping(args = {})
        @source            = args[:source] || source
        data               = args[:data]
        field_processor    = integration::FieldProcessor.new(data: data)
        mapping_fields     = args[:mapping_fields] || get_mapping_fields

        mapping_fields.map do |field|
          field_name = field.try(:destination_field) || field[0]
          field_content = process_content(
            field.try(:content) || field[1],
            field_processor
          )

          "#[#{field_name}]#\n#{field_content}"
        end&.join("\n\n")
      end

      # This lists the fields defined by this plugin that can be used in the
      # mapping
      def source_fields
        @source_fields ||= {}
        if validate_source
            @source_fields[source] ||= begin
            fields_file = File.join(@templates_dir, "#{source}.fields")
            File.readlines(fields_file).map(&:chomp)
          end
        end
      end

      # This returns a sample of valid entry for the Mappings Manager
      def sample
        @sample ||= {}
        if validate_source
            @sample[source] ||= begin
            sample_file = File.join(@templates_dir, "#{source}.sample")
            File.read(sample_file)
          end
        end
      end

      private

      # This method returns the default location in which plugins should look
      # for their templates.
      def default_templates_dir
        @default_templates_dir ||= begin
          File.join(Configuration.paths_templates_plugins, integration::meta[:name].to_s)
        end
      end

      def get_mapping_fields
        mapping = Mapping.includes(:mapping_fields).find_by(
          component: integration::Engine.plugin_name.to_s,
          source: source,
          destination: rtp_id ? "rtp_#{rtp_id}" : nil
        )

        # fetch mapping_fields through mapping or default
        if mapping && mapping.mapping_fields.any?
          mapping.mapping_fields
        else
          integration::Mapping::DEFAULT_MAPPING[source.to_sym]
        end
      end

      def process_content(content, field_processor)
        content.gsub(/{{\s?#{integration::Engine.plugin_name.to_s}\[(\S*?)\]\s?}}/) do |field|
          name = field.split(/\[|\]/)[1]

          if source_fields.include?(name)
            field_processor.value(field: name)
          else
            "Field [#{field}] not recognized by the integration"
          end
        end
      end

      def validate_source
        allowed_sources = integration::Mapping::DEFAULT_MAPPING.keys.map(&:to_s)
        @source = if allowed_sources.include?(source)
                    source
                  else
                    nil
                  end
      end
    end
  end
end
