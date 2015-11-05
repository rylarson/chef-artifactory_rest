$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
require 'chefspec'
require 'chefspec/berkshelf'
require 'artifactory'

def mock_commons_io(classifier: nil)
  allow(Artifactory::Resource::Artifact).to receive(:latest_version)
                                                .with(group: group_id, name: artifact_id, version: artifact_version, repos: repository_keys.first)
                                                .and_return('2.4')
  allow(Artifactory::Resource::Artifact).to receive(:gavc_search)
                                                .with(group: group_id, name: artifact_id, version: '2.4', repos: repository_keys.first, classifier: classifier)
                                                .and_return([double('artifact', download_uri: download_uri)])
end

describe 'artifactory_rest_lwrp_test::gavc_download' do
  let(:group_id) {'commons-io'}
  let(:artifact_id) {'commons-io'}
  let(:artifact_version) {'2.*'}
  let(:repository_keys) {['repo']}
  let(:endpoint) {'http://artifactory.example.com/artifactory'}
  let(:resolved_version) {'2.4'}
  let(:resolved_repo) {repository_keys.first}
  let(:packaging) {'jar'}
  let(:download_path) {'/tmp/download'}


  context 'with no classifier set' do
    let(:download_uri) {"#{endpoint}/api/storage/#{resolved_repo}/#{group_id}/#{artifact_id}/#{resolved_version}/#{artifact_id}-#{resolved_version}.jar"}
    subject(:chef_run) do
      mock_commons_io

      ChefSpec::SoloRunner.new(step_into: ['artifactory_rest_gavc_download']) do |node|
        node.set[:artifactory_rest][:gavc_download][:endpoint] = endpoint
        node.set[:artifactory_rest][:gavc_download][:path] = download_path
        node.set[:artifactory_rest][:gavc_download][:group_id] = group_id
        node.set[:artifactory_rest][:gavc_download][:artifact_id] = artifact_id
        node.set[:artifactory_rest][:gavc_download][:version] = artifact_version
        node.set[:artifactory_rest][:gavc_download][:packaging] = packaging
        node.set[:artifactory_rest][:gavc_download][:repository_keys] = repository_keys
      end.converge(described_recipe)
    end

    it { is_expected.to gavc_download(download_path)
                            .with_group_id(group_id)
                            .with_artifact_id(artifact_id)
                            .with_version(artifact_version)
                            .with_repository_keys(repository_keys)
                            .with_endpoint(endpoint) }
    it { is_expected.to create_remote_file(%r[.+#{download_uri}.+#{group_id}.+#{artifact_id}.+#{artifact_version}.+]).with_source(download_uri) }
  end

  context 'with classifier set' do
    let(:download_uri) {"#{endpoint}/api/storage/#{resolved_repo}/#{group_id}/#{artifact_id}/#{resolved_version}/#{artifact_id}-#{resolved_version}-#{classifier}.jar"}
    let(:classifier) {'sources'}
    subject(:chef_run) do
      mock_commons_io(classifier: classifier)

      ChefSpec::SoloRunner.new(step_into: ['artifactory_rest_gavc_download']) do |node|
        node.set[:artifactory_rest][:gavc_download][:endpoint] = endpoint
        node.set[:artifactory_rest][:gavc_download][:path] = download_path
        node.set[:artifactory_rest][:gavc_download][:group_id] = group_id
        node.set[:artifactory_rest][:gavc_download][:artifact_id] = artifact_id
        node.set[:artifactory_rest][:gavc_download][:version] = artifact_version
        node.set[:artifactory_rest][:gavc_download][:packaging] = packaging
        node.set[:artifactory_rest][:gavc_download][:repository_keys] = repository_keys
        node.set[:artifactory_rest][:gavc_download][:classifier] = classifier
      end.converge(described_recipe)
    end

    it { is_expected.to gavc_download(download_path)
                            .with_group_id(group_id)
                            .with_artifact_id(artifact_id)
                            .with_version(artifact_version)
                            .with_repository_keys(repository_keys)
                            .with_endpoint(endpoint) }
    it { is_expected.to create_remote_file(%r[.+#{download_uri}.+#{group_id}.+#{artifact_id}.+#{artifact_version}.+#{classifier}.+])
                            .with_source(download_uri) }
  end
end
