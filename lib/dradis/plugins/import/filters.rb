module Dradis
  module Plugins
    module Import
      module Filters
        class << self
          # -- Class Methods --------------------------------------------------------
          # One Import plugin can define several filters (e.g. to query different
          # endpoints of a remote API).
          #
          # Use this method in your Importer to register different filters, pass a
          # block or a class.
          #
          # Examples:
          #
          # register_filter :by_osvdb_id do
          #   def c
          # end
          def add(plugin, label, filter, &block)
            filter ||= Class.new(Dradis::Plugins::Import::Filters::Base)
            filter.class_eval(&block) if block_given?

            unless filter.method_defined?(:query)
              raise NoMethodError, "query() is not declared in the #{label.inspect} filter"
            end

            base = Dradis::Plugins::Import::Filters::Base
            unless filter.ancestors.include?(base)
              raise "#{label.inspect} is not a #{base}"
            end

            _filters[plugin]        = {} unless _filters.key?(plugin)
            _filters[plugin][label] = filter
          end

          # Provides access to filters by plugin
          # :api: public
          def [](plugin)
            _filters[plugin]
          end

          # :api: private
          def _filters
            @filters ||= {}
          end
        end
      end
    end
  end
end
