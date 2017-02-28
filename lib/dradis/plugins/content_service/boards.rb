module Dradis::Plugins::ContentService
  module Boards
    extend ActiveSupport::Concern

    included do
    end

    def all_boards
      class_for(:board).where(project_id: project.id)
    end
  end
end
