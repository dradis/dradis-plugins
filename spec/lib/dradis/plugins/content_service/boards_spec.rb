require 'rails_helper'

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

        expect(service.all_boards).to include(board)
      end
    end

    describe '#create_board' do
      it 'creates a board' do
        node = create(:node, project: project)
        service.create_board name: 'Test Board', node_id: node.id

        expect(project.reload.boards.where(name: 'Test Board')).to_not be_nil
      end
    end
  end
end
