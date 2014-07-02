# The plugin's FieldProcessor is in charge of understanding the incoming data
# from the uploaded file and extracting the fields to populate the template.
# Plugins are expected to overwrite the value() method.
#
module Dradis
  module Plugins
    module Upload

      class FieldProcessor
        attr_reader :data

        def initialize(args={})
          @data = args[:data]
          post_initialize(args)
        end

        # Inspect the data object currently stored in this processor instance
        # and extract the value of the requested field.
        #
        # Subclasses will overwrite this method.
        def value(args={})
          field = args[:field]
          "Sorry, this plugin doesn't define a FieldProcessor (called for [#{field}])"
        end
      end

    end
  end
end
