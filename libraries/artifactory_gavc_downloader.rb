$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]
require 'artifactory'

class ArtifactoryDownloader
  include ::Artifactory::Resource

  def initialize(endpoint: raise('endpoint is required'),
                 username: nil,
                 password: nil)
    Artifactory.endpoint = endpoint
    Artifactory.username = username if username
    Artifactory.password = password if password
    Artifactory.ssl_verify = false
  end

  def resolve_download_uri(group: nil, artifact: nil, version: nil, classifier: nil, repos: nil, packaging: nil)
    repos = repos.join(',') unless repos.is_a? String
    newest_version = find_newest_version_for_coordinates(group: group, artifact: artifact, version: version, repos: repos)
    version = newest_version if wildcarded_version?(version)
    resolved_artifact = get_artifact_with_coordinates(group: group, artifact: artifact, version: version, newest_version: newest_version, classifier: classifier, packaging: packaging, repos: repos)
    raise DependencyResolutionError.new("Error resolving artifact with group: #{group}, name: #{artifact}, version constraint #{version}") if resolved_artifact.nil?
    resolved_artifact.download_uri
  end

  private

  def coordinates_from_string(coordinate_string)
    coordinate_string.split(/:|@/)
  end

  def find_newest_version_for_coordinates(group: raise('group is required'),
                                          artifact: raise('artifact is required'),
                                          version: raise('version is required'),
                                          repos: raise('repo(s) are required'))
    return version if (!wildcarded_version?(version) && !snapshot_version?(version))
    resolved_version = Artifact.latest_version(group: group, name: artifact, version: version, repos: repos)
    raise DependencyResolutionError.new("Error resolving artifact with group: #{group}, name: #{artifact}, version constraint #{version}") if resolved_version.nil?
    resolved_version
  end

  def get_artifact_with_coordinates(group: raise('group is required'),
                                    artifact: raise('artifact is required'),
                                    version: raise('version is required'),
                                    newest_version: raise('newest_version is required'),
                                    classifier: raise('classifier is required'),
                                    packaging: raise('packaging is required'),
                                    repos: raise('repo(s) are required'))
    artifacts = Artifact.gavc_search(group: group, name: artifact, version: version, classifier: classifier, repos: repos)
    # We have to do our own classifier matching because doing a gavc search with no classifier returns all artifacts
    artifacts.find { |it| it.download_uri =~ /#{newest_version}#{"-#{classifier}" if classifier}.#{packaging}/ }
  end

  def wildcarded_version?(constraint)
    constraint.include?('*') || constraint.include?('?')
  end

  def snapshot_version?(constraint)
    constraint.include?('SNAPSHOT')
  end
end

class DependencyResolutionError < RuntimeError;
end
