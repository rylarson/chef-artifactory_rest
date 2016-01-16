$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
require 'chefspec'
require 'chefspec/berkshelf'
require 'artifactory'

def mock_artifactory_search_results(classifier: nil)
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
    let(:expected_remote_file_name) { %r[.+#{download_uri} specified by: .+#{group_id}.+#{artifact_id}.+#{artifact_version}.+] }
    subject(:chef_run) do
      mock_artifactory_search_results

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
    it { is_expected.to create_remote_file(expected_remote_file_name).with_source(download_uri) }
  end

  context 'with authentication set' do
    let(:endpoint_with_auth) { endpoint.sub('://', "://#{username}:#{password}@") }
    let(:download_uri_path) { "api/storage/#{resolved_repo}/#{group_id}/#{artifact_id}/#{resolved_version}/#{artifact_id}-#{resolved_version}.jar" }
    let(:download_uri_with_auth) {"#{endpoint_with_auth}/#{download_uri_path}"}
    let(:download_uri) {"#{endpoint}/#{download_uri_path}"}
    let(:username) { 'artifactory_user' }
    let(:password) { 'artifactory_password' }
    let(:expected_remote_file_name) { %r[.+#{download_uri_with_auth} specified by: .+#{group_id}.+#{artifact_id}.+#{artifact_version}.+] }
    subject(:chef_run) do
      mock_artifactory_search_results

      ChefSpec::SoloRunner.new(step_into: ['artifactory_rest_gavc_download']) do |node|
        node.set[:artifactory_rest][:gavc_download][:endpoint] = endpoint
        node.set[:artifactory_rest][:gavc_download][:path] = download_path
        node.set[:artifactory_rest][:gavc_download][:group_id] = group_id
        node.set[:artifactory_rest][:gavc_download][:artifact_id] = artifact_id
        node.set[:artifactory_rest][:gavc_download][:version] = artifact_version
        node.set[:artifactory_rest][:gavc_download][:packaging] = packaging
        node.set[:artifactory_rest][:gavc_download][:repository_keys] = repository_keys
        node.set[:artifactory_rest][:gavc_download][:username] = username
        node.set[:artifactory_rest][:gavc_download][:password] = password
      end.converge(described_recipe)
    end

    it { is_expected.to gavc_download(download_path)
                            .with_group_id(group_id)
                            .with_artifact_id(artifact_id)
                            .with_version(artifact_version)
                            .with_repository_keys(repository_keys)
                            .with_endpoint(endpoint) }
    it { is_expected.to create_remote_file(expected_remote_file_name)
                            .with_source(download_uri_with_auth) }
  end

  context 'with classifier set' do
    let(:download_uri) {"#{endpoint}/api/storage/#{resolved_repo}/#{group_id}/#{artifact_id}/#{resolved_version}/#{artifact_id}-#{resolved_version}-#{classifier}.jar"}
    let(:classifier) {'sources'}
    let(:expected_remote_file_name) { %r[.+#{download_uri} specified by: .+#{group_id}.+#{artifact_id}.+#{artifact_version}.+#{classifier}.+] }
    subject(:chef_run) do
      mock_artifactory_search_results(classifier: classifier)

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
    it { is_expected.to create_remote_file(expected_remote_file_name)
                            .with_source(download_uri) }
  end
end
