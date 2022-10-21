require 'rails_helper'

class TestEngine < ::Rails::Engine
  include ::Dradis::Plugins::Base
  addon_settings :test_engine do
  end
end

describe Dradis::Plugins::Base do
  before(:each) do
    TestEngine::settings.reset_defaults!
  end

  describe '#enabled?' do
    it 'returns default value' do
      expect(TestEngine.enabled?).to eq(false)
    end
  end
  describe '#enable!' do
    it 'sets enabled to true' do
      expect { TestEngine.enable! }.to change {
        TestEngine.enabled?
      }.from(false).to(true)
    end
  end
  describe '#disable!' do
    it 'sets enabled to false' do
      TestEngine.enable!
      expect { TestEngine.disable! }.to change {
        TestEngine.enabled?
      }.from(true).to(false)
    end
  end
end
