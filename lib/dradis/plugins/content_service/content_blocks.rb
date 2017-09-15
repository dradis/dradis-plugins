module Dradis::Plugins::ContentService
  module ContentBlocks
    extend ActiveSupport::Concern

    def all_content_blocks
      ContentBlock.where(project_id: project.id)
    end
  end
end
