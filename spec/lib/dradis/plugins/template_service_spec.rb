require 'rails_helper'

# To run, execute from Dradis main app folder:
#   bin/rspec [dradis-plugins path]/spec/lib/dradis/plugins/template_service_spec.rb
describe Dradis::Plugins::TemplateService do
  describe '#process_template' do
    let(:data) { double }
    let(:plugin) { Dradis::Plugins::Qualys }
    let(:project) { create(:project, :with_report_template_properties) }
    let(:template_service) do
      Dradis::Plugins::TemplateService.new(plugin: plugin, project: project)
    end
    let(:mapping) {
      create(:mapping, component: 'qualys', source: 'was-issue', destination: "rtp_#{project.report_template_properties_id}")
    }
    let(:liquid_mapping_fields) {
      create_list(:mapping_field, 2, content: "{% if issue.evidence %}\n{% endif %} }}")
    }
    let(:qualys_mapping_fields) {
      create_list(:mapping_field, 2, content: '{{ qualys[was-issue.title] }}')
    }

    before do
      allow(data).to receive(:name).and_return('VULNERABILITY')
      allow(template_service).to receive(:template).and_return('was-issue')
      allow(template_service).to receive(:apply_default_mapping).and_return(['test content'])
      allow(template_service).to receive(:apply_mapping).and_return(['test content'])
    end

    context 'with default mappings' do
      it 'applies default mappings when no mapping exists' do
        expect(template_service).to receive(:apply_default_mapping)
        expect(template_service).to_not receive(:apply_mapping)

        template_service.process_template(data: data)
      end
    end

    context 'with custom mappings' do
      before do
        allow(template_service).to receive(:mapping).and_return(mapping)
        allow(mapping).to receive(:mapping_fields).and_return(qualys_mapping_fields)
      end

      it 'applies mappings when a mapping matching the uploader & template exists' do
        expect(template_service).to receive(:apply_mapping).with(mapping.mapping_fields)
        expect(template_service).to_not receive(:apply_default_mapping)

        template_service.process_template(data: data)
      end
    end

    context 'liquid' do
      before do
        allow(template_service).to receive(:mapping).and_return(mapping)
        allow(mapping).to receive(:mapping_fields).and_return(liquid_mapping_fields)
      end

      it 'does not parse the liquid data as fields' do
        expect(template_service).to_not receive(:fields)

        template_service.process_template(data: data)
      end
    end
  end
end
