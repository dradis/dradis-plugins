require 'rails_helper'

# To run, execute from Dradis main app folder:
#   bin/rspec [dradis-plugins path]/spec/lib/dradis/plugins/mapping_service_spec.rb
describe Dradis::Plugins::MappingService do
  describe '#apply_mapping' do
    let(:data) { double }
    let(:liquid_mapping_field) {
      create(:mapping_field, content: "{% if issue.evidence %}\n{% endif %} }}")
    }
    let(:integration) { Dradis::Plugins::Qualys }
    let(:project) { create(:project, :with_report_template_properties) }
    let(:qualys_mapping_field) {
      create(:mapping_field, destination_field: 'Test Field', content: 'test content')
    }
    let(:mapping_service) do
      Dradis::Plugins::MappingService.new(
        integration: integration,
        destination: "rtp_#{project.report_template_properties_id}"
      )
    end
    let(:mapping_processed) do
      mapping_service.apply_mapping(source: 'was_issue', data: data)
    end

    before do
      allow(data).to receive(:name).and_return('VULNERABILITY')
    end

    context 'with default mappings' do
      it 'applies default mappings when no mapping exists' do
        expect(mapping_processed).to include("#[Title]#\n")
        expect(mapping_processed).not_to include("#[Test Field]#\n")
      end
    end

    context 'with custom mappings' do
      it 'applies mappings when a mapping matching the uploader & source exists' do
        allow(mapping_service).to receive(:get_mapping_fields).and_return([qualys_mapping_field])

        expect(mapping_processed).to include("#[Test Field]#\ntest content")
        expect(mapping_processed).not_to include("#[Title]#\n")
      end

      context 'with liquid content' do
        it 'does not parse the liquid data as fields' do
          allow(mapping_service).to receive(:get_mapping_fields).and_return([liquid_mapping_field])

          expect(mapping_processed).to include("{% if issue.evidence %}\n{% endif %} }}")
        end
      end
    end
  end
end
