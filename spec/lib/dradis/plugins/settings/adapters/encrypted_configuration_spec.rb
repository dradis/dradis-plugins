#
# This spec must be run from Dradis root dir.
#
# Configuration init from:
#   https://github.com/rails/rails/blob/main/activesupport/test/encrypted_configuration_test.rb
#
require 'rails_helper'

describe Dradis::Plugins::Settings::Adapters::EncryptedConfiguration do

  subject do
    ec = Dradis::Plugins::Settings::Adapters::EncryptedConfiguration.new(:rspec)
    ec.config_path = @credentials_config_path
    ec.key_path = @credentials_key_path
    ec
  end

  DEFAULT_CONFIG = { rspec: { key: :lorem_ipsum, key2: :dolor_sit } }.to_yaml.freeze

  before(:all) do
    @tmpdir = Dir.mktmpdir('config-')
    @credentials_config_path = File.join(@tmpdir, 'credentials.yml.enc')
    @credentials_key_path = File.join(@tmpdir, 'master.key')

    File.write(@credentials_key_path, ActiveSupport::EncryptedConfiguration.generate_key)

    @credentials = ActiveSupport::EncryptedConfiguration.new(
      config_path: @credentials_config_path, key_path: @credentials_key_path,
      env_key: 'RAILS_MASTER_KEY', raise_if_missing_key: true
    )

    @credentials.write(DEFAULT_CONFIG)
  end

  after(:all) do
    FileUtils.rm_rf @tmpdir
  end

  describe '#delete' do
    it 'removes a value from disk' do
      subject.delete(:key2)

      @credentials.instance_variable_set('@config', nil)
      expect(@credentials.config[:rspec].key?(:key)).to be(true)
      expect(@credentials.config[:rspec].key?(:key2)).to be(false)
      @credentials.write(DEFAULT_CONFIG)
    end
  end

  describe '#exists' do
    it 'finds an existing value' do
      expect(subject.exists?(:key)).to be(true)
    end
    it 'detects an inexisting value' do
      expect(subject.exists?(:key3)).to be(false)
    end
  end

  describe '#read' do
    it 'loads an already existing value' do
      expect(subject.read(:key)).to eq(:lorem_ipsum)
    end
  end

  describe '#write' do
    it 'stores a value on disk' do
      subject.write(:new_key, :new_value)
      @credentials.instance_variable_set('@config', nil)
      expect(@credentials.config[:rspec][:new_key]).to eq(:new_value)
      @credentials.write(DEFAULT_CONFIG)
    end
  end
end
