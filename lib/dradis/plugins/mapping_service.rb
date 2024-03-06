module Dradis
  module Plugins
    class MappingService
      attr_accessor :plugin, :rtp_id, :source, :templates_dir

      def initialize(args = {})
        @plugin           = args.fetch(:plugin)
        @rtp_id           = args.fetch(:rtp_id)
        @templates_dir    = args.fetch(:templates_dir, default_templates_dir)
      end

      def apply_mapping(args = {})
        @source            = args[:source]
        data               = args[:data]
        field_processor    = plugin::FieldProcessor.new(data: data)

        mapping_fields.map do |field|
          field_name = field.try(:destination_field) || field[0]
          field_content = process_content(
            field.try(:content) || field[1],
            field_processor
          )

          "#[#{field_name.titleize}]#\n\n#{field_content}"
        end&.join("\n\n")
      end

      # This lists the fields defined by this plugin that can be used in the
      # mapping
      def integration_fields
        @integration_fields ||= {}
        @integration_fields[source] ||= begin
          fields_file = File.join(templates_dir, "#{source}.fields")
          File.readlines(fields_file).map(&:chomp)
        end
      end

      # This returns a sample of valid entry for the Mappings Manager
      def sample
        @sample ||= {}
        @sample[template] ||= begin
          sample_file = File.join(templates_dir, "#{template}.sample")
          File.read(sample_file)
        end
      end

      private

      # This method returns the default location in which plugins should look
      # for their templates.
      def default_templates_dir
        @default_templates_dir ||= begin
          File.join(Configuration.paths_templates_plugins, plugin::meta[:name].to_s)
        end
      end

      def mapping_fields
        mapping = Mapping.includes(:mapping_fields).find_by(
          component: plugin::Mapping.component_name,
          source: source,
          destination: rtp_id ? "rtp_#{rtp_id}" : nil
        )

        # fetch mapping_fields through mapping or default
        if mapping && mapping.mapping_fields.any?
          mapping.mapping_fields
        else
          plugin::Mapping.default_mapping[source]
        end
      end

      def process_content(content, field_processor)
        content.gsub(/{{\s?#{plugin::Mapping.component_name}\[(\S*?)\]\s?}}/) do |field|
          name = field.split(/\[|\]/)[1]

          if integration_fields.include?(name)
            field_processor.value(field: name)
          else
            "Field [#{field}] not recognized by the plugin"
          end
        end
      end
    end
  end
end