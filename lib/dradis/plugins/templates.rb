module Dradis
  module Plugins
    module Templates
      extend ActiveSupport::Concern

      LEGACY_FIELDS_REGEX = /%(\S+?)%/
      LEGACY_MAPPING_REFERENCE = {
        'burp' => {
          'html_evidence' => 'html_evidence',
          'html_issue' => 'issue',
          'xml_evidence' => 'evidence',
          'xml_issue' => 'issue'
        },
        'qualys' => {
          'asset_evidence' => 'asset-evidence',
          'asset_issue' => 'asset-issue',
          'vuln_evidence' => 'evidence',
          'vuln_element' => 'element',
          'was_evidence' => 'was-evidence',
          'was_issue' => 'was-issue'
        }
      }

      included do
        # Keep track of any templates the plugin defines
        paths['dradis/templates'] = 'templates'
      end

      module ClassMethods
        def copy_templates(args={})
          destination = args.fetch(:to)

          destination_dir = File.join(destination, plugin_name.to_s)
          FileUtils.mkdir_p(destination_dir) if plugin_templates.any?

          plugin_templates.each do |template|
            destination_file = File.join(destination_dir, File.basename(template))

            next if skip?(destination_file)

            Rails.logger.info do
              "Updating templates for #{plugin_name} plugin. "\
              "Destination: #{destination}"
            end
            FileUtils.cp(template, destination_file)
          end
        end

        def migrate_templates_to_mappings(args = {})
          return unless paths['dradis/templates'].existent.any?
          templates_dir = args.fetch(:from)
          @integration_templates_dir = File.join(templates_dir, plugin_name.to_s)
          @integration_name = plugin_name.to_s

          if uploaders.count > 1
            migrate_multiple_uploaders(@integration_name)
          else
            template_files = Dir["#{@integration_templates_dir}/*.template"]
            template_files.each do |template_file|
              source = File.basename(template_file, '.template')
              # create a mapping & mapping_fields for each field in the file
              migrate(template_file, source)
            end
          end
        end

        def plugin_templates(args={})
          @templates ||= begin
            if paths['dradis/templates'].existent.any?
              Dir["#{paths['dradis/templates'].existent.first}/*"]
            else
              []
            end
          end
        end

        private

        def create_mapping(mapping_source)
          destination = @rtp_id ? "rtp_#{@rtp_id}" : nil

          Mapping.find_or_create_by!(
            component: @integration_name,
            source: mapping_source,
            destination: destination
          )
        end

        def create_mapping_fields(mapping, template_file)
          template_fields = parse_template_fields(template_file)

          # create a mapping_field for each field in the .template file
          template_fields.each do |field_title, field_content|
            # set source_field by taking the first match to the existing %% syntax
            source_field = field_content.match(LEGACY_FIELDS_REGEX)
            source_field = source_field ? source_field[1] : 'custom text'

            updated_content = update_syntax(field_content)

            mapping.mapping_fields.find_or_create_by!(
              source_field: source_field,
              destination_field: field_title,
              content: updated_content
            )
          end
        end

        def migrate(template_file, source)
          rtp_ids = defined?(Dradis::Pro) ? ReportTemplateProperties.ids : [nil]
          rtp_ids.each do |rtp_id|
            @rtp_id = rtp_id

            ActiveRecord::Base.transaction do
              mapping = create_mapping(source)
              create_mapping_fields(mapping, template_file)
            end
          end
          File.rename template_file, "#{template_file}.legacy"
        end

        # previously our integrations with multiple uploaders (Burp, Qualys) had inconsistent
        # template names (some included the uploader, some didn't ex. burp issue vs html_evidence)
        # they have been renamed to follow a consistent 'uploader_entity' structure, but
        # in order to migrate the old templates to the db with the new names as the source
        # we need to reference an object in the integration that maps the new name to the old one
        def migrate_multiple_uploaders(integration)
          LEGACY_MAPPING_REFERENCE[integration].each do |source_field, legacy_template_name|
            template_file = Dir["#{@integration_templates_dir}/#{legacy_template_name}.template*"]
            if template_file.any? { |file| File.exist?(file) }
              migrate(template_file[0], source_field)
            end
          end
        end

        def parse_template_fields(template_file)
          template_content = File.read(template_file)
          FieldParser.source_to_fields(template_content)
        end

        def update_syntax(field_content)
          # turn the %% syntax into the new
          # '{{ <integration>[was-issue.title] }}' format
          field_content.gsub(LEGACY_FIELDS_REGEX) do |content|
            "{{ #{@integration_name}[#{content[1..-2]}] }}"
          end
        end

        # Normally we want to copy all templates so that the user always has
        # the latest version.
        #
        # However, if it's a '.template' file, the user might have edited their
        # local copy, and we don't want to override their changes.  So only
        # copy .template files over if the user has no copy at all (i.e. if
        # this is the first time they've started Dradis since this template was
        # added.)
        def skip?(file_path)
          File.extname(file_path) == ".template" || File.extname(file_path) == ".fields"
        end
      end
    end
  end
end
