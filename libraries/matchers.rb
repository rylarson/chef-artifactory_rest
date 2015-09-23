if defined?(ChefSpec)
  ChefSpec.define_matcher(:artifactory_rest)

  def gavc_download(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:artifactory_rest_gavc_download, :download, resource)
  end
end
