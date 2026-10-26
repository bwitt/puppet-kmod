# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'kmod' do
  context 'with defines set to present' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PUPPET
          kmod::alias { 'bond0':
            source => 'bonding',
          }
          kmod::blacklist { 'pcspkr': }
          kmod::install { 'dccp': }
          kmod::option { 'bonding mode':
            module => 'bonding',
            option => 'mode',
            value  => '1',
          }
        PUPPET
      end
    end

    describe file('/etc/modprobe.d/bond0.conf') do
      its(:content) { is_expected.to match %r{^alias bond0 bonding$} }
    end

    describe file('/etc/modprobe.d/blacklist.conf') do
      its(:content) { is_expected.to match %r{^blacklist pcspkr$} }
    end

    describe file('/etc/modprobe.d/dccp.conf') do
      its(:content) { is_expected.to match %r{^install dccp /bin/true$} }
    end

    describe file('/etc/modprobe.d/bonding.conf') do
      its(:content) { is_expected.to match %r{^options bonding mode=1$} }
    end
  end

  context 'with defines set to absent' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PUPPET
          kmod::alias { 'bond0':
            ensure => absent,
            source => 'bonding',
          }
          kmod::blacklist { 'pcspkr':
            ensure => absent,
          }
          kmod::install { 'dccp':
            ensure => absent,
          }
          kmod::option { 'bonding mode':
            ensure => absent,
            module => 'bonding',
            option => 'mode',
            value  => '1',
          }
        PUPPET
      end
    end

    describe file('/etc/modprobe.d/bond0.conf') do
      its(:content) { is_expected.not_to match %r{bond0} }
    end

    describe file('/etc/modprobe.d/blacklist.conf') do
      its(:content) { is_expected.not_to match %r{pcspkr} }
    end

    describe file('/etc/modprobe.d/dccp.conf') do
      its(:content) { is_expected.not_to match %r{dccp} }
    end

    describe file('/etc/modprobe.d/bonding.conf') do
      its(:content) { is_expected.not_to match %r{bonding} }
    end
  end

  # Containers share the host kernel and can't load modules, so use one the
  # host already has loaded (overlay backs Docker's storage driver).
  context 'with kmod::load' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) { "kmod::load { 'overlay': }" }
    end

    describe file('/etc/modules-load.d/overlay.conf') do
      its(:content) { is_expected.to match %r{^overlay$} }
    end
  end
end
