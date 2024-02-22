module Dradis
  module Plugins
    module Templates
      extend ActiveSupport::Concern

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

        def copy_templates_to_db(args={})
          from = args.fetch(:from)
          from_dir = File.join(from, plugin_name.to_s)
          templates = Dir["#{from_dir}/*"]

          templates.each do |template|
            next unless template.include?(".template")
            mapping_source = File.basename(template, ".template")

            mapping = Mapping.find_or_create_by(
              component: plugin_name.to_s,
              source: mapping_source,
              destination: ''
            )

            file_data = File.open(template).read
            file_data.split("\n\n").reject{ |l| l.empty? }.each do |line|
              line_data = line.split("\n").reject{ |l| l.empty? }
              source_field = line_data.first.delete("#[").delete("]#")
              content = line_data.last.gsub(/%(?=\S)/, "{{ #{plugin_name}[").gsub("%","] }}")
              destination_field = content.scan(/(?<=\.)\w+/).join(", ")

              mapping.mapping_fields.find_or_create_by(
                source_field: source_field,
                content: content,
                destination_field: destination_field
              )
            end

            File.delete(template) if File.exists? template
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

        # Normally we want to copy all templates so that the user always has
        # the latest version.
        #
        # However, if it's a '.template' file, the user might have edited their
        # local copy, and we don't want to override their changes.  So only
        # copy .template files over if the user has no copy at all (i.e. if
        # this is the first time they've started Dradis since this template was
        # added.)
        def skip?(file_path)
          File.exist?(file_path) && File.extname(file_path) == ".template"
        end
      end
    end
  end
end
