module Dradis
  module Plugins
    module Templates
      module Samples
        extend ActiveSupport::Concern

        included do
          # Keep track of any templates the plugin defines
          paths['dradis/templates'] = 'templates'
        end

        module ClassMethods
          def copy_samples(args = {})
            destination = args.fetch(:to)

            destination_dir = File.join(destination, plugin_name.to_s)
            FileUtils.mkdir_p(destination_dir) if integration_samples.any?

            integration_samples.each do |template|
              destination_file = File.join(destination_dir, File.basename(template))

              Rails.logger.info do
                "Updating templates for #{plugin_name} plugin. "\
                "Destination: #{destination}"
              end
              FileUtils.cp(template, destination_file)
            end
          end

          private

          def integration_samples(args = {})
            @templates ||= begin
              if paths['dradis/templates'].existent.any?
                Dir["#{paths['dradis/templates'].existent.first}/*.sample"]
              else
                []
              end
            end
          end
        end
      end
    end
  end
end
