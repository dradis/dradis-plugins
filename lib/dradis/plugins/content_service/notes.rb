module Dradis::Plugins::ContentService
  module Notes
    extend ActiveSupport::Concern

    def all_notes
      Note.where(category: Category.report)
    end

    def create_note(args={})
      cat  = args.fetch(:category, default_note_category)
      node = args.fetch(:node, default_node_parent)
      text = args.fetch(:text, default_note_text)

      note = node.notes.new(
        text: text,
        category: cat,
        author: default_author
      )

      if note.valid?
        note.save
      else
        try_rescue_from_length_validation(
          model: note,
          field: :text,
          text: text,
          msg: 'Error in create_note()'
        )
      end

      note
    end

    private
    def default_note_category
      @default_note_category ||= Category.default
    end

    def default_note_text
      "create_note() invoked by #{plugin} without a :text parameter"
    end
  end
end
