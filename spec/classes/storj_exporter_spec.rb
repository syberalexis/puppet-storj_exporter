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

          # Compilation
          it {
            is_expected.to compile
          }
        end
      end
    end
  end
end
