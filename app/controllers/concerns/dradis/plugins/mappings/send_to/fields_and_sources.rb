module Dradis
  module Plugins
    module Mappings
      module SendTo
        # Shared by "send to" integrations' MappingsControllers (e.g. Jira,
        # VSTS, ServiceNow) to list Dradis Report Templates as mapping
        # sources. Distinct from Dradis::Plugins::Mappings::Base, which
        # handles the opposite direction (mapping inbound upload data into
        # Dradis fields).
        module FieldsAndSources
          extend ActiveSupport::Concern

          def set_rtp_fields_and_sources
            set_rtp_fields
            set_sources
          end

          def set_rtp_fields
            @rtp_fields = ReportTemplateProperties.all.filter_map do |rtp|
              next if rtp.issue_fields.count == 0
              [rtp.id, rtp.issue_fields.map(&:name)]
            end.to_h
          end

          def set_sources
            @sources = ReportTemplateProperties.all.group_by(&:plugin_name).map do |plugin_name, rtps|
              mapped_rtps = rtps.map do |rtp|
                suffix = ''
                options = {}
                if rtp.issue_fields.count == 0
                  suffix = ' (no issue fields)'
                  options = { disabled: 'disabled' }
                end
                [rtp.title + suffix, rtp.id, options]
              end
              [plugin_name.titleize, mapped_rtps]
            end
          end
        end
      end
    end
  end
end
