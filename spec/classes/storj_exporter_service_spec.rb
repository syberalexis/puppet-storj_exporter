require 'spec_helper'

describe 'storj_exporter::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      arch = os.split('-').last
      let(:facts) do
        os_facts.merge('os' => { 'architecture' => arch })
      end

      [
        {
          bin_dir: '/usr/local/bin',
          user: 'storj_exporter',
          group: 'storj_exporter',
          ensure: 'running',
          port: 9651,
          storj_host_address: '127.0.0.1',
          storj_api_port: 14_002,
        },
      ].each do |parameters|
        context "with parameters #{parameters}" do
          let(:params) do
            parameters
          end

          s_bin_dir = parameters[:bin_dir]
          s_user = parameters[:user]
          s_group = parameters[:group]
          s_ensure = parameters[:ensure]
          s_port = parameters[:port]
          s_storj_host_address = parameters[:storj_host_address]
          s_storj_api_port = parameters[:storj_api_port]

          case s_ensure
          when 'running'
            s_file_ensure = 'file'
            s_service_ensure = 'running'
          when 'stopped'
            s_file_ensure = 'file'
            s_service_ensure = 'stopped'
          else
            s_file_ensure = 'absent'
            s_service_ensure = 'stopped'
          end

          # Compilation
          it {
            is_expected.to compile
          }

          # Service
          it {
            is_expected.to contain_file('/lib/systemd/system/storj_exporter.service').with(
              'ensure' => s_file_ensure,
            ).with_content(
              "# THIS FILE IS MANAGED BY PUPPET
[Unit]
Description=Storj Exporter service
Wants=storagenode.service
After=storagenode.service

[Service]
User=#{s_user}
Group=#{s_group}
Type=simple
Environment=STORJ_EXPORTER_PORT=#{s_port}
Environment=STORJ_HOST_ADDRESS=#{s_storj_host_address}
Environment=STORJ_API_PORT=#{s_storj_api_port}
ExecStart=/usr/bin/python3 #{s_bin_dir}/storj-exporter
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
",
            ).that_notifies('Service[storj_exporter]')

            is_expected.to contain_service('storj_exporter').with(
              'ensure' => s_service_ensure,
              'enable' => true,
            )
          }
        end
      end
    end
  end
end
