module Dradis::Plugins::ContentService
  module Notes
    extend ActiveSupport::Concern

    def all_notes
      project.notes.where(category: Category.report)
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

    def create_many_notes(notes)
      notes.each do |note|
        note[:category_id] ||= default_note_category.id
        note[:node_label] ||= default_node_parent.label
        note[:node_id] = project.nodes.find_by_label(note[:node_label]).id
        note[:text] ||= default_note_text

        note[:text] = truncate_text(text: note[:text])
      end

      time = Time.now.strftime('%Y-%m-%d %H:%M:%S')
      values = notes.map{ |note| "('#{default_author}', #{note[:category_id]}, '#{time}', #{note[:node_id]}, #{ActiveRecord::Base.connection.quote(note[:text])}, '#{time}')" }.join(',')
      sql = "INSERT INTO notes (author, category_id, created_at, node_id, text, updated_at) VALUES #{values}"

      ActiveRecord::Base.connection.execute(sql)
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
