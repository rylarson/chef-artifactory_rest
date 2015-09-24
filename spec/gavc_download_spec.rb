$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
require 'chefspec'
require 'chefspec/berkshelf'
require 'artifactory'

def mock_commons_io(classifier: nil)
  allow(Artifactory::Resource::Artifact).to receive(:latest_version)
                                                .with(group: 'commons-io', name: 'commons-io', version: '2.*', repos: 'repo')
                                                .and_return('2.4')
  allow(Artifactory::Resource::Artifact).to receive(:gavc_search)
                                                .with(group: 'commons-io', name: 'commons-io', version: '2.4', repos: 'repo', classifier: classifier)
                                                .and_return([double('artifact', download_uri: 'http://artifactory.example.com/artifactory/api/storage/libs-thirdparty-local/commons-io/commons-io/2.4/commons-io-2.4-sources.jar'),
                                                             double('artifact', download_uri: 'http://artifactory.example.com/artifactory/api/storage/libs-thirdparty-local/commons-io/commons-io/2.4/commons-io-2.4.jar')])
end

describe 'artifactory_rest_lwrp_test::gavc_download' do
  context 'with no classifier set' do
    subject(:chef_run) do
      mock_commons_io

      ChefSpec::SoloRunner.new(step_into: ['artifactory_rest_gavc_download']) do |node|
        node.set[:artifactory_rest][:gavc_download][:endpoint] = 'http://artifactory.example.com/artifactory'
        node.set[:artifactory_rest][:gavc_download][:path] = '/tmp/download'
        node.set[:artifactory_rest][:gavc_download][:group_id] = 'commons-io'
        node.set[:artifactory_rest][:gavc_download][:artifact_id] = 'commons-io'
        node.set[:artifactory_rest][:gavc_download][:version] = '2.*'
        node.set[:artifactory_rest][:gavc_download][:packaging] = 'jar'
        node.set[:artifactory_rest][:gavc_download][:repository_keys] = ['repo']
      end.converge(described_recipe)
    end

    it { is_expected.to gavc_download(chef_run.node[:artifactory_rest][:gavc_download][:path])
                            .with_group_id(chef_run.node[:artifactory_rest][:gavc_download][:group_id])
                            .with_artifact_id(chef_run.node[:artifactory_rest][:gavc_download][:artifact_id])
                            .with_version(chef_run.node[:artifactory_rest][:gavc_download][:version])
                            .with_repository_keys(chef_run.node[:artifactory_rest][:gavc_download][:repository_keys])
                            .with_endpoint(chef_run.node[:artifactory_rest][:gavc_download][:endpoint]) }
    it { is_expected.to create_remote_file(/.*/).with_source('http://artifactory.example.com/artifactory/api/storage/libs-thirdparty-local/commons-io/commons-io/2.4/commons-io-2.4.jar') }
  end

  context 'with classifier set' do
    subject(:chef_run) do
      mock_commons_io(classifier: 'sources')

      ChefSpec::SoloRunner.new(step_into: ['artifactory_rest_gavc_download']) do |node|
        node.set[:artifactory_rest][:gavc_download][:endpoint] = 'http://artifactory.example.com/artifactory'
        node.set[:artifactory_rest][:gavc_download][:path] = '/tmp/download'
        node.set[:artifactory_rest][:gavc_download][:group_id] = 'commons-io'
        node.set[:artifactory_rest][:gavc_download][:artifact_id] = 'commons-io'
        node.set[:artifactory_rest][:gavc_download][:version] = '2.*'
        node.set[:artifactory_rest][:gavc_download][:packaging] = 'jar'
        node.set[:artifactory_rest][:gavc_download][:repository_keys] = ['repo']
        node.set[:artifactory_rest][:gavc_download][:classifier] = 'sources'
      end.converge(described_recipe)
    end

    it { is_expected.to gavc_download(chef_run.node[:artifactory_rest][:gavc_download][:path])
                            .with_group_id(chef_run.node[:artifactory_rest][:gavc_download][:group_id])
                            .with_artifact_id(chef_run.node[:artifactory_rest][:gavc_download][:artifact_id])
                            .with_version(chef_run.node[:artifactory_rest][:gavc_download][:version])
                            .with_repository_keys(chef_run.node[:artifactory_rest][:gavc_download][:repository_keys])
                            .with_endpoint(chef_run.node[:artifactory_rest][:gavc_download][:endpoint]) }
    it { is_expected.to create_remote_file(/.*/).with_source('http://artifactory.example.com/artifactory/api/storage/libs-thirdparty-local/commons-io/commons-io/2.4/commons-io-2.4-sources.jar') }
  end
end
