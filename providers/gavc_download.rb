use_inline_resources

def whyrun_supported?
  true
end

action :download do
  if new_resource.classifier.to_s.empty? then
    new_resource.classifier = nil
  end
  downloader = ArtifactoryDownloader.new(endpoint: new_resource.endpoint, username: new_resource.username, password: new_resource.password)
  download_uri = downloader.resolve_download_uri(group: new_resource.group_id,
                                                 artifact: new_resource.artifact_id,
                                                 version: new_resource.version,
                                                 classifier: new_resource.classifier,
                                                 repos: new_resource.repository_keys,
                                                 packaging: new_resource.packaging)

  resource_name = "Downloading file #{download_uri} specified by: #{new_resource.to_s}"
  if new_resource.username && new_resource.password then
    download_uri.sub!(/^(.*):\/\//, "\\1://#{new_resource.username}:#{new_resource.password}@")
  end
  converge_by(resource_name) do
    # Delegate to remote_file for idempotency
    remote_file resource_name do
      source download_uri
      path new_resource.path
    end
  end
end
