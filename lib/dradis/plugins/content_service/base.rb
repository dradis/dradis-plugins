require 'dradis/plugins/content_service/boards'
require 'dradis/plugins/content_service/categories'
require 'dradis/plugins/content_service/content_blocks'
require 'dradis/plugins/content_service/core'
require 'dradis/plugins/content_service/evidence'
require 'dradis/plugins/content_service/issues'
require 'dradis/plugins/content_service/nodes'
require 'dradis/plugins/content_service/notes'
require 'dradis/plugins/content_service/properties'

module Dradis::Plugins::ContentService
  class Base
    include Core

    include Boards        if defined?(Dradis::Pro)
    include Categories
    include ContentBlocks if defined?(Dradis::Pro)
    include Evidence
    include Issues
    include Nodes
    include Notes
    include Properties    if defined?(Dradis::Pro)

     ActiveSupport.run_load_hooks(:content_service, self)
  end
end
