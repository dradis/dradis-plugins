require 'rails_helper'

# To run, execute from Dradis main app folder:
#   bin/rspec [dradis-plugins path]/spec/lib/dradis/plugins/template_service_spec.rb
describe Dradis::Plugins::TemplateService do
  describe '#process_template' do
    let(:data) { double }
    let(:plugin) { Dradis::Plugins::Nessus }
    let(:template_service) do
      Dradis::Plugins::TemplateService.new(plugin: plugin)
    end

    context 'liquid' do
      before do
        allow(data).to receive(:name).and_return('ReportHost')
        allow(template_service).to receive(:template_source).and_return(
          "{% if issue.evidence %}\n{% end if %}"
        )
      end

      it 'does not parse the liquid data as fields' do
        expect(template_service).to_not receive(:fields)

        template_service.process_template(data: data)
      end
    end
  end
end
