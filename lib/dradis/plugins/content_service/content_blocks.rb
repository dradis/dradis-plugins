module Dradis::Plugins::ContentService
  module ContentBlocks
    extend ActiveSupport::Concern

    def all_content_blocks
      @project.content_blocks
    end
  end
end
