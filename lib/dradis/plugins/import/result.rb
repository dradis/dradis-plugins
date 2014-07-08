module Dradis::Plugins::Import
  class Result
    attr_accessor :description, :tags, :title

    def initialize(args={})
      @description = args[:description] || "The Import plugin didn't provide a :description for this result."
      @tags = args[:tags] || []
      @title = args[:description] || "The Import plugin didn't provide a :title for this result."
    end
  end
end
