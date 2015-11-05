use_inline_resources

def whyrun_supported?
  true
end

action :download do
  converge_by("Downloading file specified by #{new_resource.to_s}") do
    downloader = ArtifactoryDownloader.new(endpoint: new_resource.endpoint)
    download_uri = downloader.resolve_download_uri(group: new_resource.group_id,
                                                   artifact: new_resource.artifact_id,
                                                   version: new_resource.version,
                                                   classifier: new_resource.classifier,
                                                   repos: new_resource.repository_keys,
                                                   packaging: new_resource.packaging)

    # Delegate to remote_file for idempotency
    remote_file "Downloading file #{download_uri} by: #{new_resource.to_s}" do
      source download_uri
      path new_resource.path
    end
  end
end
