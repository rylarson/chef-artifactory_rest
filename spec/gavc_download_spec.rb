$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
require 'chefspec'
require 'chefspec/berkshelf'
require 'artifactory'

describe 'artifactory_rest_lwrp_test::gavc_download' do
  context 'with only required attributes set' do
    subject(:chef_run) do
      allow(Artifactory::Resource::Artifact).to receive(:latest_version)
                                                    .with(group: 'group_id', name: 'artifact_id', version: '5.*', repos: 'repo')
                                                    .and_return('5.0.0')
      allow(Artifactory::Resource::Artifact).to receive(:gavc_search)
                                                    .with(group: 'group_id', name: 'artifact_id', version: '5.0.0', repos: 'repo', classifier: '')
                                                    .and_return([double('artifact', download_uri: 'file:///TEST_URI')])

      ChefSpec::SoloRunner.new(step_into: ['artifactory_rest_gavc_download']) do |node|
        node.set[:artifactory_rest][:gavc_download][:endpoint] = 'TEST_ENDPOINT'
        node.set[:artifactory_rest][:gavc_download][:path] = '/tmp/download'
        node.set[:artifactory_rest][:gavc_download][:group_id] = 'group_id'
        node.set[:artifactory_rest][:gavc_download][:artifact_id] = 'artifact_id'
        node.set[:artifactory_rest][:gavc_download][:version] = '5.*'
        node.set[:artifactory_rest][:gavc_download][:repository_keys] = ['repo']
      end.converge(described_recipe)
    end

    it { is_expected.to gavc_download(chef_run.node[:artifactory_rest][:gavc_download][:path])
                            .with_group_id(chef_run.node[:artifactory_rest][:gavc_download][:group_id])
                            .with_artifact_id(chef_run.node[:artifactory_rest][:gavc_download][:artifact_id])
                            .with_version(chef_run.node[:artifactory_rest][:gavc_download][:version])
                            .with_repository_keys(chef_run.node[:artifactory_rest][:gavc_download][:repository_keys])
                            .with_endpoint(chef_run.node[:artifactory_rest][:gavc_download][:endpoint]) }
    it { is_expected.to create_remote_file(/.*/).with_source('file:///TEST_URI') }
  end

  context 'with all attributes set' do

  end
end
