module Dradis::Plugins::Import
  class Result
    attr_accessor :description, :id, :tags, :title, :state

    def initialize(args = {})
      @description = args[:description] || "The Import plugin didn't provide a :description for this result."
      @id          = args[:id]          || "The Import plugin didn't provide an :id for this result."
      @tags        = args[:tags]        || []
      @title       = args[:title]       || "The Import plugin didn't provide a :title for this result."
      @state       = args[:state]       || nil
    end
  end
end
