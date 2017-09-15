module Dradis::Plugins::ContentService
  module ContentBlocks
    extend ActiveSupport::Concern

    def all_content_blocks
      ContentBlock.where(project_id: project.id)
    end

    def create_content_block(args={})
      name    = args.fetch(:name, default_content_block_name)
      user_id = args.fetch(:user_id)
      content = args.fetch(:content, default_content_block_content)

      content_block = ContentBlock.new(
        content: content,
        name: name,
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

    def default_content_block_name
      "create_content_block() invoked by #{plugin} without a :name parameter"
    end
  end
end
