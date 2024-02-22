require 'rails_helper'

RSpec.describe Dradis::Plugins::Templates do

  describe '#copy_templates_to_db' do
    let(:plugin) { Dradis::Plugins::Qualys }
    let(:default_dir) { "../dradis-plugins/spec/files/defaults/templates/" }
    let(:from_dir) { "../dradis-plugins/spec/files/templates/" }

    context 'when templates are present' do
      before do
        FileUtils.rm_r(from_dir)
        FileUtils.cp_r(default_dir, from_dir)
        Dradis::Plugins::Acunetix::Engine.copy_templates_to_db(from: from_dir)
      end

      it 'creates mapping for evidence' do
        expect(Mapping.where(component: 'acunetix', source: 'evidence').count).to be(1)
      end

      it 'creates correct mapping fields for evidence for FalsePositive' do
        mapping_field = MappingField.where(source_field: 'FalsePositive', destination_field: 'is_false_positive').first
        expect(mapping_field).to_not be_nil
        expect(mapping_field.content).to eq("{{ acunetix[evidence.is_false_positive] }}")
      end

      it 'creates correct mapping fields for evidence for AOP' do
        mapping_field = MappingField.where(source_field: 'AOP').first
        content = "| {{ acunetix[evidence.aop_source_file] }} | {{ acunetix[evidence.aop_source_line] }} | {{ acunetix[evidence.aop_additional] }} |"
        destination_field = "aop_source_file, aop_source_line, aop_additional"

        expect(mapping_field).to_not be_nil
        expect(mapping_field.destination_field).to eq(destination_field)
        expect(mapping_field.content).to eq(content)
      end

      it 'creates mapping for report_items' do
        expect(Mapping.where(component: 'acunetix', source: 'report_item').count).to be(1)
      end

      it 'does not create mapping for scan' do
        expect(Mapping.where(component: 'acunetix', source: 'scan').count).to be(0)
      end

      it 'creates mapping fields' do
        expect(MappingField.count).to be(19)
      end

      it 'deletes the template files after processing' do
        expect(Dir[from_dir + "/acunetix/*"].count).to be(2)
      end
    end
  end
end
