require 'spec_helper'

describe 'storj_exporter::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      arch = os.split('-').last
      let(:facts) do
        os_facts.merge('os' => { 'architecture' => arch })
      end

      [
        {
          version: '0.2.5',
          base_dir: '/opt',
          bin_dir: '/usr/local/bin',
          download_extension: 'tar.gz',
          download_url: 'https://github.com/anclrii/Storj-Exporter/archive/0.2.5.tar.gz',
          extract_command: 'ls',
          manage_user: true,
          manage_group: true,
          user: 'storj_exporter',
          group: 'storj_exporter',
          user_shell: '/bin/false',
          extra_groups: [],
          python_required_packages: ['requests', 'prometheus_client'],
        },
      ].each do |parameters|
        context "with parameters #{parameters}" do
          let(:params) do
            parameters
          end

          s_version = parameters[:version]
          s_base_dir = parameters[:base_dir]
          s_bin_dir = parameters[:bin_dir]
          s_download_extension = parameters[:download_extension]
          s_download_url = parameters[:download_url]
          s_extract_command = parameters[:extract_command]
          s_manage_user = parameters[:manage_user]
          s_manage_group = parameters[:manage_group]
          s_user = parameters[:user]
          s_group = parameters[:group]
          s_user_shell = parameters[:user_shell]
          s_extra_groups = parameters[:extra_groups]
          s_python_required_packages = parameters[:python_required_packages]

          # Compilation
          it {
            is_expected.to compile
          }

          # Install
          it {
            is_expected.to contain_archive("/tmp/storj-exporter-#{s_version}.#{s_download_extension}").with(
              'ensure'          => 'present',
              'extract'         => true,
              'extract_path'    => s_base_dir,
              'source'          => s_download_url,
              'checksum_verify' => false,
              'creates'         => "/opt/Storj-Exporter-#{s_version}",
              'cleanup'         => true,
              'extract_command' => s_extract_command,
            )
            is_expected.to contain_file("#{s_base_dir}/Storj-Exporter-#{s_version}/storj-exporter.py").with(
              'owner'  => 'root',
              'group'  => '0',
              'mode'   => '0555',
            )
            is_expected.to contain_file("#{s_bin_dir}/storj-exporter").with(
              'ensure' => 'link',
              'target' => "#{s_base_dir}/Storj-Exporter-#{s_version}/storj-exporter.py",
            )

            # User
            if s_manage_user
              is_expected.to contain_user(s_user).with(
                'ensure' => 'present',
                'system' => true,
                'groups' => [s_group] + s_extra_groups,
                'shell'  => s_user_shell,
              )
            else
              is_expected.not_to contain_user(s_user)
            end
            # Group
            if s_manage_group
              is_expected.to contain_group(s_group).with(
                'ensure' => 'present',
                'system' => true,
              )
            else
              is_expected.not_to contain_group(s_group)
            end

            if s_python_required_packages
              s_python_required_packages.each do |package|
                is_expected.to contain_python__pip(package).with(
                  'ensure'       => 'present',
                  'pkgname'      => package,
                  'pip_provider' => 'pip3',
                )
              end
            end
          }
        end
      end
    end
  end
end
