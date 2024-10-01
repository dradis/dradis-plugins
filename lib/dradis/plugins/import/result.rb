module Dradis::Plugins::Import
  class Result
    attr_accessor :callback, :description, :id, :tags, :title

    def initialize(args={})
      @callback = args[:callback] || Proc.new {}
      @description = args[:description] || "The Import plugin didn't provide a :description for this result."
      @id          = args[:id]          || "The Import plugin didn't provide an :id for this result."
      @tags        = args[:tags]        || []
      @title       = args[:title]       || "The Import plugin didn't provide a :title for this result."
    end
  end
end
