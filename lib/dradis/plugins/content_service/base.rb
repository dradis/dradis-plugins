require 'dradis/plugins/content_service/boards'

module Dradis::Plugins::ContentService
  class Base
    include Core

    include Boards
    include Evidence
    include Issues
    include Nodes
    include Notes

     ActiveSupport.run_load_hooks(:content_service, self)
  end
end
