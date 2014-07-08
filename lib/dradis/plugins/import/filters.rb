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
          def add(label, filter, &block)
            filter ||= Class.new(Dradis::Plugins::Import::Filters::Base)
            filter.class_eval(&block) if block_given?

            unless filter.method_defined?(:query)
              raise NoMethodError, "query() is not declared in the #{label.inspect} strategy"
            end

            base = Dradis::Plugins::Import::Filters::Base
            unless filter.ancestors.include?(base)
              raise "#{label.inspect} is not a #{base}"
            end

            _filters[label] = filter
          end

          # Provides access to strategies by label
          # :api: public
          def [](label)
            _filters[label]
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