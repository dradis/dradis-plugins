module Dradis::Plugins::ContentService
  module Boards
    extend ActiveSupport::Concern

    def all_boards
      project.methodology_library.boards
    end

    def create_board(args={})
      name    = args.fetch(:name, default_board_name)
      node_id = args.fetch(:node_id, project.methodology_library.id)
      Board.create(name: name, project_id: project.id, node_id: node_id)
    end

    private
    def default_board_name
      "create_board() invoked by #{plugin} without a :name parameter"
    end
  end
end
