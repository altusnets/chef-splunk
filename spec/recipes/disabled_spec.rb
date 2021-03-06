require 'spec_helper'

describe 'chef-splunk::disabled' do
  context 'splunk is disabled' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
        node.force_default['splunk']['disabled'] = true
      end.converge(described_recipe)
    end

    it 'stops the splunk service' do # ~FC005
      expect(chef_run).to stop_service('splunk')
    end

    it 'uninstalls the splunk and splunkforwarder packages' do
      expect(chef_run).to remove_package(%w(splunk splunkforwarder))
    end

    it 'disables splunk startup at boot' do
      expect(chef_run).to run_execute('/opt/splunkforwarder/bin/splunk disable boot-start')
    end

    it 'does not log debug message' do
      expect(chef_run).to_not write_log('splunk is not disabled')
    end
  end

  context 'splunk is not disabled' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
        node.force_default['splunk']['disabled'] = false
      end.converge(described_recipe)
    end

    let(:message) do
      'The chef-splunk::disabled recipe was added to the node, ' \
      'but the attribute to disable splunk was not set.'
    end

    it 'logged debug message and returns' do
      expect(chef_run).to write_log('splunk is not disabled')
        .with(level: :debug, message: message)
    end
  end
end
