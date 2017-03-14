module Dradis::Plugins::ContentService
  module Boards
    extend ActiveSupport::Concern

    def all_boards
      Board.where(project_id: project.id)
    end

    def create_board(args={})
      name = args.fetch(:name, default_board_name)
      Board.create(name: name, project_id: project.id)
    end

    private
    def default_board_name
      "create_board() invoked by #{plugin} without a :name parameter"
    end
  end
end
