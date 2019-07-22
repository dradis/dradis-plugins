require 'rails_helper'

# To run, execute from Dradis main app folder:
#   bin/rspec [dradis-plugins path]/spec/lib/dradis/plugins/content_service/boards_spec.rb
describe Dradis::Plugins::ContentService::Boards do
  let(:plugin)  { Dradis::Plugins::Nessus }
  let(:project) { create(:project) }
  let(:service) do
    Dradis::Plugins::ContentService::Base.new(
      plugin: plugin,
      logger: Rails.logger,
      project: project
    )
  end

  describe 'Boards' do
    describe '#all_boards' do
      it 'returns all the project-level boards' do
        board = create(:board, project: project)
        node = create(:node, project: project)
        node_board = create(:board, node: node, project: project)

        boards = service.all_boards

        expect(boards).to include(board)
        expect(boards).to_not include(node_board)
      end
    end

    describe '#create_board' do
      it 'creates a board without a node' do
        service.create_board(name: 'NodelessBoard')

        expect(project.reload.boards.where(name: 'NodelessBoard')).to_not be_nil
      end

      it 'creates a board with a node' do
        node = create(:node, project: project)
        service.create_board(name: 'NodeBoard', node_id: node.id)

        expect(project.reload.boards.where(name: 'NodeBoard')).to_not be_nil
      end
    end
  end
end
