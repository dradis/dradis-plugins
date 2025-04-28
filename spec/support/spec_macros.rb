module Dradis::Plugins::SpecMacros
  extend ActiveSupport::Concern

  def stub_content_service
    @content_service = Dradis::Plugins::ContentService::Base.new(
      logger: Logger.new(STDOUT),
      plugin: Dradis::Plugins::Nexpose
    )

    # Stub content_service methods
    # They return their argument hashes as objects mimicking
    # nodes, issues, etc
    allow(@content_service).to receive(:create_node) do |args|
      OpenStruct.new(args)
    end
    allow(@content_service).to receive(:create_note) do |args|
      OpenStruct.new(args)
    end
    allow(@content_service).to receive(:create_issue) do |args|
      OpenStruct.new(args)
    end
    allow(@content_service).to receive(:create_evidence) do |args|
      OpenStruct.new(args)
    end
  end
end
