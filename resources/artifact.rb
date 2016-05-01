property :endpoint, String, name_property: true
property :username, String
property :password, String
property :search_type, String, required: true
property :search, String, default: 'name'
property :destination, String, default: Chef::Config['file_cache_path']
property :property_hash, Hash, required: false
property :download_path, identity: true, desired_state: false
property :checksums, Array, default: %w(md5 sha1)
default_action :download

def init
  require 'artifactory'
  require 'net/http'
  Chef::Resource.send(:include, Artifactory::Resource)
end

def set_artifactory
  Resource::Artifactory.configure do |config|
    config.endpoint = new_resource.endpoint
    config.username = new_resource.username
    config.password = new_resource.password
  end
end

def artifactory_checksum_search
  artifact = Resource::Artifact.checksum_search(search_type.to_sym => search).first
  artifact
end

def artifactory_search
  artifact = Resource::Artifact.seach(name: search).first
  artifact
end

def _properties(artifact)
  begin
    property_list = artifact.properties
  rescue Artifactory::Error::HTTPError
    property_list = {}
  end
  property_list.merge!(property_hash)
  property_list
end

def artifact_uri
  uri = nil
  uri = artifactory_checksum_search.download_uri if checksums.include?(search_type)
  uri = artifactory_search.download_uri if search_type == 'name'
  log "Artifact search at #{endpoint} for #{search_type}: #{search} returned no results" do
    level :error
    only_if uri.nil?.to_s
  end
  uri
end

def find_artifact
  artifact = nil
  artifact = artifactory_checksum_search if checksums.include?(search_type)
  artifact = artifactory_search if search_type == 'name'
  artifact
end

def form_request(property_list, artifact)
  uri = URI.parse(artifact.uri)
  uri.query = URI.encode_www_form(property_list)
  uri.query.prepend('properties=')
  http = Net::HTTP.new(uri.host, uri.port)
  puts uri.request_uri
  req = Net::HTTP::Put.new(uri.request_uri.tr('&', '|'))
  req['Content-Type'] = 'text/plain'
  req.basic_auth username, password
  response = http.request(req)
  response
end

def update_properties(artifact)
  property_list = _properties(artifact)
  property_list
end

action :add_properties do
  init
  set_artifactory
  artifact = find_artifact
  property_list = update_properties(artifact)
  response = form_request(property_list, artifact)
  log 'Unable to update access timestamp in artifactory' do
    message "\n#{response.body}"
    level :warn
  end unless response.body.nil?
end

action :download do
  init
  set_artifactory
  uri = artifact_uri
  download_path = ::File.join(destination, ::File.basename(uri))
  directory ::File.dirname(download_path) do
    recursive true
  end
  remote_file download_path do
    source uri
  end
end
