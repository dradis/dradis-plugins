
# When you call provides :upload in your Engine, this module gets included. It
# provides two features:
#
# a) an .uploaders() class method that by default responds with a single array
# item pointing to the engine's parent. This will be used by the framework to
# locate the ::Importer object that does the upload heavy lifting.
#
# If your plugin implements more than one uploader, each one would be contained
# in its own namespace, and you should overwrite the .uploaders() method to
# return an array of all these namespaces. See method definition for an
# example.
#
# b) it adds a .meta() method to the engine's parent module, containing the
# name, description and version of the add-on.
#
# Again, if you implement more than one uploader, make sure you create a
# .meta() class-level method in each of your namespaces.
#

module Dradis::Plugins::Upload::Base
  def self.included(base)
    base.extend ClassMethods
    base.parent.extend NamespaceClassMethods

    base.class_eval do
    end
  end

  module ClassMethods
    # Return the list of modules that provide upload functionality. This is
    # useful if one plugin provides uploading functionality for more than one
    # file type (e.g. the Projects plugin allows you to upload a Package or a
    # Template).
    #
    # The default implementation just returns this plugin's namespace (e.g.
    # Dradis::Plugins::Nessus). If a plugin provides multiple uploaders, they
    # can override this method:
    #   def self.uploders
    #     [
    #       Dradis::Plugins::Projects::Package,
    #       Dradis::Plugins::Projects::Template
    #     ]
    #   end
    def uploaders()
      [parent]
    end
  end

  module NamespaceClassMethods
    def meta
      {
        name: self::Engine::plugin_name,
        description: self::Engine::plugin_description,
        version: self::VERSION::STRING
      }
    end
  end
end