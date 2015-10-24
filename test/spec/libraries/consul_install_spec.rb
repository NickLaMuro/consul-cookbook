require 'spec_helper'
require_relative '../../../libraries/consul_install'

describe ConsulCookbook::Resource::ConsulInstall do
  step_into(:consul_install)
  let(:node_attributes) { Hash.new }
  let(:default_chefspec_options) { {platform: 'ubuntu', version: '14.04'} }
  let(:chefspec_options) { node_attributes.merge default_chefspec_options }

  context 'for a binary install' do
    let(:node_attributes) { { normal_attributes: { install_method: 'binary' } } }
    recipe 'consul_spec::consul_install'

    it { is_expected.to create_directory('/etc/consul') }
    it { is_expected.to create_directory('/var/lib/consul') }

    it do is_expected.to create_libartifact_file('consul-0.5.2')
      .with(artifact_name: 'consul',
            artifact_version: '0.5.2',
            install_path: '/srv',
            remote_url: "https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip",
            remote_checksum: '171cf4074bfca3b1e46112105738985783f19c47f4408377241b868affa9d445')
    end

    it { is_expected.to create_link('/usr/local/bin/consul').with(to: '/srv/consul/current/consul') }

    # Don't install via other methods
    it { is_expected.to_not install_package('consul') }
  end

  context 'for a binary delete' do
    let(:node_attributes) { { normal_attributes: {install_method: 'binary', consul_install_action: :uninstall} } }
    recipe 'consul_spec::consul_install'

    it { is_expected.to delete_directory('/srv/consul') }
    it { is_expected.to delete_link('/usr/local/bin/consul') }

    # Don't uninstall via other methods
    it { is_expected.to_not remove_package('consul') }
  end

  context 'for a package install' do
    let(:node_attributes) { { normal_attributes: { install_method: 'package' } } }
    recipe 'consul_spec::consul_install'

    it { is_expected.to create_directory('/etc/consul') }
    it { is_expected.to create_directory('/var/lib/consul') }

    it { is_expected.to install_package('consul').with(version: '0.5.2') }

    # Don't install via other methods
    it { is_expected.to_not create_libartifact_file('consul-0.5.2') }
    it { is_expected.to_not create_link('/usr/local/bin/consul') }
  end

  context "for a package uninstall" do
    let(:node_attributes) { { normal_attributes: {install_method: 'package', consul_install_action: :uninstall} } }
    recipe 'consul_spec::consul_install'

    it { is_expected.to remove_package('consul') }

    # Don't uninstall via other methods
    it { is_expected.to_not delete_directory('/srv/consul') }
    it { is_expected.to_not delete_link('/usr/local/bin/consul') }
  end
end
