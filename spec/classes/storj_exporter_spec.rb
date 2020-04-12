require 'spec_helper'

describe 'storj_exporter' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      arch = os.split('-').last
      let(:facts) do
        os_facts.merge('os' => { 'architecture' => arch })
      end

      [
        {
          manage_python: false,
        },
      ].each do |parameters|
        context "with parameters #{parameters}" do
          let(:params) do
            parameters
          end

          s_manage_python = parameters[:manage_python].nil? ? true : parameters[:manage_python]

          # Compilation
          it {
            is_expected.to compile
          }

          # Implementation
          it {
            is_expected.to contain_class('storj_exporter::install')
            is_expected.to contain_class('storj_exporter::service')

            if s_manage_python
              is_expected.to contain_class('python').with(
                'version' => 'python3',
              )
            else
              is_expected.not_to contain_class('python')
            end
          }
        end
      end
    end
  end
end
