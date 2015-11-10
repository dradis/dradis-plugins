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
