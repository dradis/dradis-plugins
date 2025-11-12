module Dradis
  module Plugins
    module Thor
      def self.included(base)
        base.extend(ClassMethods)

        base.class_eval do
          # Keep track of any templates the plugin defines
          paths['dradis/thorfiles'] = 'lib/tasks'
        end
      end

      module ClassMethods
        def load_thor_tasks
          plugin_thorfiles.each do |thorfile|
            require thorfile
          end
        end

        def plugin_thorfiles(args = {})
          if paths['dradis/thorfiles'].existent.any?
            Dir['%s/thorfile.rb' % paths['dradis/thorfiles'].existent]
          else
            []
          end
        end
      end
    end
  end
end
