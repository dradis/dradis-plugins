module Dradis::Plugins::ContentService
  module ContentBlocks
    extend ActiveSupport::Concern

    def all_content_blocks
      ContentBlock.where(project_id: project.id).sort_by { |cb| cb.title.downcase }
    end

    def create_content_block(args={})
      block_group    = args.fetch(:block_group, default_content_block_group)
      content        = args.fetch(:content, default_content_block_content)
      user_id        = args.fetch(:user_id)

      content_block = ContentBlock.new(
        content: content,
        block_group: block_group,
        project_id: project.id,
        user_id: user_id
      )

      if content_block.valid?
        content_block.save
      else
        try_rescue_from_length_validation(
          model: content_block,
          field: :content,
          text: content,
          msg: 'Error in create_content_block()',
          tail: plugin_details
        )
      end
    end

    private

    def default_content_block_content
      "create_content_block() invoked by #{plugin} without a :content parameter"
    end

    def default_content_block_group
      "create_content_block() invoked by #{plugin} without a :block_group parameter"
    end
  end
end
