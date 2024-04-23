module Dradis
  module Plugins
    module Templates
      module MigrateTemplates
        extend ActiveSupport::Concern

        # Apr 2024 migration to move from .template files
        # to db-backed mappings. Can be removed in Apr 2026

        LEGACY_FIELDS_REGEX = /%(\S+?)%/.freeze
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
        }.freeze

        module ClassMethods
          def migrate_templates_to_mappings(args = {})
            # return if the integration doesn't provide any templates ex. projects, cve
            return unless paths['dradis/templates'].existent.any?
            @integration_name = plugin_name.to_s
            # return if templates have already been migrated (mappings exist for the integration)
            return if ::Mapping.where(component: @integration_name).any?

            templates_dir = args.fetch(:from)
            integration_templates_dir = File.join(templates_dir, @integration_name)

            if uploaders.count > 1
              migrate_multiple_uploaders(@integration_name, integration_templates_dir)
            else
              template_files = Dir["#{integration_templates_dir}/*.template"]
              return unless template_files.any?

              template_files.each do |template_file|
                next unless File.exist?(template_file)
                source = File.basename(template_file, '.template')
                # create a mapping & mapping_fields for each field in the file
                migrate(template_file, source)
              end
            end
          end

          private

          def create_mapping(mapping_source, destination = nil)
            ::Mapping.find_or_create_by!(
              component: @integration_name,
              source: mapping_source,
              destination: destination
            )
          end

          def create_mapping_fields(mapping, template_file)
            template_fields = parse_template_fields(template_file)
            return unless template_fields

            # create a mapping_field for each field in the .template file
            template_fields.each do |field_title, field_content|
              # set source_field by taking the first match to the existing %% syntax
              source_field = field_content.match(LEGACY_FIELDS_REGEX)
              source_field = source_field ? source_field[1] : 'Custom Text'

              updated_content = update_syntax(field_content)

              mapping.mapping_fields.find_or_create_by!(
                source_field: source_field,
                destination_field: field_title,
                content: updated_content
              )
            end
          end

          def migrate(template_file, source)
            destinations = if defined?(Dradis::Pro)
              ReportTemplateProperties.with_fields_defined.map(&:as_mapping_destination)
            else
              [nil]
            end

            destinations.each do |destination|
              ActiveRecord::Base.transaction do
                mapping = create_mapping(source, destination)
                create_mapping_fields(mapping, template_file)
              end
            end
            rename_file(template_file)
          end

          # previously our integrations with multiple uploaders (Burp, Qualys) had inconsistent
          # template names (some included the uploader, some didn't ex. burp issue vs html_evidence)
          # they have been renamed to follow a consistent 'uploader_entity' structure, but
          # in order to migrate the old templates to the db with the new names as the source
          # we need to reference an object in the integration that maps the new name to the old one
          def migrate_multiple_uploaders(integration, templates_dir)
            return unless LEGACY_MAPPING_REFERENCE[integration]

            LEGACY_MAPPING_REFERENCE[integration].each do |source_field, legacy_template_name|
              template_file = Dir["#{templates_dir}/#{legacy_template_name}.template*"]
              if template_file.any? { |file| File.exist?(file) }
                migrate(template_file[0], source_field)
              end
            end
          end

          def parse_template_fields(template_file)
            if File.file?(template_file)
              template_content = File.read(template_file)
              FieldParser.source_to_fields(template_content)
            end
          end

          def rename_file(template_file)
            # Don't rename if it's already been renamed.
            # Ex burp issue.template is used for both issue and evidence mapping
            if !template_file.include?('.legacy') && File.file?(template_file)
              File.rename template_file, "#{template_file}.legacy"
            end
          end

          def update_syntax(field_content)
            # turn the %% syntax into the new
            # '{{ <integration>[was-issue.title] }}' format
            field_content.gsub(LEGACY_FIELDS_REGEX) do |content|
              "{{ #{@integration_name}[#{content[1..-2]}] }}"
            end
          end
        end
      end
    end
  end
end
