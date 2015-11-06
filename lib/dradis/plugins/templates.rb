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

            # if we already have a copy of the template...
            if File.exist?(destination_file) &&
                # ... and our copy is newer than the plugin's copy ...
                File.ctime(destination_file) > File.ctime(template)
              # ... then don't overwrite it:
              next
            end

            Rails.logger.info{ "Updating templates for #{plugin_name} plugin. Destination: #{destination}" }
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
      end
    end
  end
end
