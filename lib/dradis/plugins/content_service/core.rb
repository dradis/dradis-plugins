module Dradis::Plugins::ContentService
  module Core
    extend ActiveSupport::Concern

    included do
      attr_accessor :logger, :plugin, :project
    end

    # ----------------------------------------------------------- Initializer
    #

    # @option plugin [Class] the 'wrapper' module of a plugin, e.g.
    #     Dradis::Plugins::Nessus
    def initialize(args={})
      self.plugin = args.fetch(:plugin)
      self.logger = args.feth(:logger, Rails.logger)
    end

    private

    def default_author
      @default_author ||= "#{plugin::Engine.plugin_name.to_s.humanize} upload plugin"
    end

    def try_rescue_from_length_validation(args={})
      model = args[:model]
      field = args[:field]
      text  = args[:text]
      msg   = args[:msg]

      logger.error{ "Trying to rescue from a :length error" }

      if model.errors[field]
        # the plugin tried to store too much information
        msg = "#[Title]#\nTruncation warning!\n\n"
        msg << "#[Error]#\np(alert alert-error). The plugin tried to store content that was too big for the DB. Review the source to ensure no important data was lost.\n\n"
        msg << text
        model.send("#{field}=", msg.truncate(65300))
      else
        # bail
        msg = "#[Title]#\n#{msg}\n\n"
        msg << "#[Description]#\nbc. #{issue.errors.inspect}\n\n"
        model.send("#{field}=", msg)
      end
      if model.valid?
        model.save
      end
    end

  end
end
