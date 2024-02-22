module Dradis
  module Plugins
    class TemplateService
      attr_accessor :logger, :plugin, :processor, :project, :template, :templates_dir

      def initialize(args = {})
        @plugin        = args.fetch(:plugin)
        @templates_dir = args[:templates_dir] || default_templates_dir
        @project       = args.fetch(:project, nil)
      end

      # For a given entry, return a text blob resulting from applying the
      # appropriate mapping to the supplied entry.
      def process_template(args = {})
        self.template = args[:template]
        data          = args[:data]
        @processor    = plugin::FieldProcessor.new(data: data)

        apply_mapping(mapping)&.join("\n\n")
      end

      def apply_mapping(mapping)
        # fetch mapping_fields through mapping or default mapping fields through plugin
        mapping_fields =
          if mapping && mapping.mapping_fields.any?
            mapping.mapping_fields
          else
            plugin::Mapping.default_mapping[template]
          end

        mapping_fields.map do |field|
          field_name = field.try(:destination_field) || field[0]
          field_content = process_content(field.try(:content) || field[1])
          "#[#{field_name.titleize}]#\n\n#{field_content}"
        end
      end

      def process_content(content)
        content.gsub(/{{\s?#{plugin.name.demodulize.downcase}\[(\S*?)\]\s?}}/) do |field|
          name = field.split(/\[|\]/)[1]

          if fields.include?(name)
            processor.value(field: name)
          else
            "Field [#{field}] not recognized by the plugin"
          end
        end
      end

      # ---------------------------------------------- Plugin Manager interface

      # This lists the fields defined by this plugin that can be used in the
      # template
      def fields
        @fields ||= {}
        @fields[template] ||= begin
          fields_file = File.join(templates_dir, "#{template}.fields")
          File.readlines(fields_file).map(&:chomp)
        end
      end

      def mapping
        return nil unless project
        rtp =
          if project.report_template_properties
            "rtp_#{project.report_template_properties_id}"
          else
            nil # allow for nil in CE
          end

        Mapping.includes(:mapping_fields).find_by(
          component: plugin.name.demodulize.downcase,
          source: template,
          destination: rtp
        )
      end

      # This returns a sample of valid entry for the Plugin Manager
      def sample
        @sample ||= {}
        @sample[template] ||= begin
          sample_file = File.join(templates_dir, "#{template}.sample")
          File.read(sample_file)
        end
      end

      # Set the plugin's item template. This is used by the Plugins Manager
      # to force the plugin to use the new_template (provided by the user)
      def set_template(args = {})
        template = args[:template]
        content  = args[:content]

        @sources ||= {}
        @sources[template] ||= {
          content: nil,
          mtime: DateTime.now
        }
        @sources[template][:content] = content
      end

      # This method returns the current template's source. It caches the
      # template based on the file's last-modified time and refreshes the
      # cached copy when it detects changes.
      def template_source
        @sources ||= {}

        # The template can change from one time to the next (via the Plugin Manager)
        template_file  = File.join(templates_dir, "#{template}.template")
        template_mtime = File.mtime(template_file)

        if @sources.key?(template)
          # refresh cached version if modified since last read
          if template_mtime > @sources[template][:mtime]
            @template[template][:mtime] = template_mtime
            @template[template][:content] = File.read(template_file)
          end
        else
          @sources[template] = {
            mtime: template_mtime,
            content: File.read(template_file)
          }
        end

        @sources[template][:content]
      end
      # --------------------------------------------- /Plugin Manager interface

      private

      # This method returns the default location in which plugins should look
      # for their templates.
      def default_templates_dir
        @default_templates_dir ||= begin
          File.join(Configuration.paths_templates_plugins, plugin::meta[:name].to_s)
        end
      end
    end
  end
end
