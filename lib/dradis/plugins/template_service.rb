module Dradis
  module Plugins
    class TemplateService
      attr_accessor :logger, :plugin, :template, :templates_dir

      def initialize(args = {})
        @plugin        = args.fetch(:plugin)
        @templates_dir = args[:templates_dir] || default_templates_dir
      end

      # ---------------------------------------------- Plugin Manager interface

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
