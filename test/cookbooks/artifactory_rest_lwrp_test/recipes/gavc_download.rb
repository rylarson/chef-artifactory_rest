directory '/tmp'

artifactory_rest_gavc_download node[:artifactory_rest][:gavc_download][:path] do
  # Required
  group_id node[:artifactory_rest][:gavc_download][:group_id]
  endpoint node[:artifactory_rest][:gavc_download][:endpoint]
  artifact_id node[:artifactory_rest][:gavc_download][:artifact_id]
  version node[:artifactory_rest][:gavc_download][:version]
  repository_keys node[:artifactory_rest][:gavc_download][:repository_keys]

  # Optional
  classifier node[:artifactory_rest][:gavc_download][:classifier] if node[:artifactory_rest][:gavc_download][:classifier]
  packaging node[:artifactory_rest][:gavc_download][:packaging] if node[:artifactory_rest][:gavc_download][:packaging]
end
