require 'rails_helper'

# To run, execute from Dradis main app folder:
#   bin/rspec [dradis-plugins path]/spec/lib/dradis/plugins/template_service_spec.rb
describe Dradis::Plugins::TemplateService do
  describe '#process_template' do
    let(:data) { double }
    let(:liquid_mapping_field) {
      create(:mapping_field, content: "{% if issue.evidence %}\n{% endif %} }}")
    }
    let(:mapping) do
      create(
        :mapping,
        component: 'qualys',
        source: 'was-issue',
        destination: "rtp_#{project.report_template_properties_id}"
        )
      end
    let(:mapping_processed) do
      template_service.process_template(data: data)
    end
    let(:plugin) { Dradis::Plugins::Qualys }
    let(:project) { create(:project, :with_report_template_properties) }
    let(:qualys_mapping_field) {
      create(:mapping_field, destination_field: 'Test Field', content: 'test content')
    }
    let(:template_service) do
      Dradis::Plugins::TemplateService.new(plugin: plugin, project: project)
    end

    before do
      allow(data).to receive(:name).and_return('VULNERABILITY')
      allow(template_service).to receive(:template).and_return('was-issue')
    end

    context 'with default mappings' do
      it 'applies default mappings when no mapping exists' do
        expect(mapping_processed).to include("#[Title]#\n\n")
        expect(mapping_processed).not_to include("#[Test Field]#\n\n")
      end
    end

    context 'with custom mappings' do
      before do
        allow(template_service).to receive(:mapping).and_return(mapping)
      end

      it 'applies mappings when a mapping matching the uploader & template exists' do
        allow(mapping).to receive(:mapping_fields).and_return([qualys_mapping_field])

        expect(mapping_processed).to include("#[Test Field]#\n\ntest content")
        expect(mapping_processed).not_to include("#[Title]#\n\n")
      end

      context 'with liquid content' do
        it 'does not parse the liquid data as fields' do
          allow(mapping).to receive(:mapping_fields).and_return([liquid_mapping_field])

          expect(mapping_processed).to include("{% if issue.evidence %}\n{% endif %} }}")
        end
      end
    end
  end
end
