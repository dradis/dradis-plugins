module Dradis
  module Plugins
    module Mappings
      module Ticketing
        # Shared by ticketing integrations' Mapping::Source classes (e.g.
        # Jira, VSTS, ServiceNow) to identify a Report Template as a mapping
        # source. Distinct from Dradis::Plugins::Mappings::Base, which
        # handles the opposite direction (mapping inbound upload data into
        # Dradis fields).
        class Source
          attr_reader :rtp_id, :source

          def initialize(args)
            if args[:source]
              @source = args[:source]
              @rtp_id = args[:source][/rtp_(\d+)/, 1]
            elsif args[:rtp_id]
              @rtp_id = args[:rtp_id]
              @source = "rtp_#{args[:rtp_id]}"
            end
          end

          def to_s
            source
          end
        end
      end
    end
  end
end
