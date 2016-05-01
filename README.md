# artifactory_rest-cookbook

This cookbook provides resources for interacting with the artifactory REST API

## Supported Platforms

This is written in pure ruby so it supports all of teh platformz

## Resources

### artifactory_rest_gavc_download

This is basically `remote_file` where the source is defined as Artifactory GAVC search parameters.

#### Attributes

| Name | Type | Description | Default | Required
| ---- | ---- | ----------- | ------- | --------
| path | String | Path to which file be downloaded | n/a | yes
| endpoint | String | Artifactory instance URI | n/a | yes
| username | String | Artifactory username | n/a | no
| password | String | Artifactory password | n/a | no
| group_id | String | Group for GAVC search | n/a | yes
| artifact_id | String | Artifact for GAVC search | n/a | yes
| version | String | Version for GAVC search | n/a | yes
| classifier | String | Classifier for GAVC search | nil | no
| packaging | String | File extension of artifact | n/a | yes
| repository_keys | Array of strings | Repositories to search | n/a | yes

#### Usage

The following will download the `commons-io-2.4-sources.jar` file to `/tmp/downloads`, assuming that Artifactory
at `http://artifactory.mycompany.com/artifactory` has that artifact in its `maven-central-cache` repository.

```ruby
artifactory_rest_gavc_download '/tmp/downloads/commons-io-2.4-sources.jar' do
  # Required
  group_id 'commons-io'
  artifact_id 'commons-io'
  endpoint 'http://artifactory.mycompany.com/artifactory'
  version '2.*'
  repository_keys 'maven-central-cache'
  packaging 'jar'

  # Optional
  classifier 'sources'
end
```
### artifactory_rest_artifact
Custom Resource for finding an artifact by name or checksum
#### Properties
| Name | Type | Description | Default | Required
| ---- | ---- | ----------- | ------- | --------
| endpoint | String | artifactory server url | resource name | no
| username | String | artifactory credentials - username | n/a | no
| password | String | artifactory credentials - password | n/a | no
| search_type | String | Search type to find artifact. Valid values are 'name' or any value contained in property checksums | 'name' | yes
| search | String | search term to find artifact. Either the name or checksum, as specified by search_type | n/a | yes
| destination | String | Directory for artifact to be downloaded to | Chef::Config['file_cache_path'] | no
| property_hash | Hash{String => String} | Hash of properties to add or replace if they already exist | n/a | no
| download_path | Identity | Location artifact is downloaded to | destination/artifact.basename | n/a
| checksums | Array[String] |valid values for search_type (other than 'name') | ['md5', 'sha1'] | no

#### Actions
| Name | Description | Default
| ---- | ----------- | -------
| :download | Downloads artifact found | yes
| :add_properties | Merges property_hash with the artifact found | no

#### Usage

``` ruby
artifact_location = artifactory_rest_artifact 'http://artifactory.mycompany.com' do
  username 'my_user'
  password 'my_password'
  search_type 'sha256'
  search '3915ed48d8764758bacb5aa9f15cd276'
  destination '/my_artifacts/this_artifact_type'
  checksums %w(sha256 sha1 md5)
end

puts "artifact exists at #{artifact_location.download_path}"
```

```ruby
artifactory_rest_artifact 'http://artifactory.mycompany.com' do
  username 'my_user'
  password 'my_password'
  search_type 'sha256'
  search '3915ed48d8764758bacb5aa9f15cd276'
  property_hash {'chef.cookbook.download_date' => Time.now.utc, 'it.hasbeen.downloaded' => 'true'}
  checksums %w(sha256 sha1 md5)
  action :update_properties
end
```

### artifactory_rest_gem

#### Properties
| Name | Type | Description | Default | Required
| ---- | ---- | ----------- | ------- | --------
| version | String | Version of the gem or 'latest' | resource name | no
| source | String | Source of the gem | n/a | no

#### Actions
| Name | Description | Default
| ---- | ----------- | -------
| :install | Installs the artifactory gem and makes it ready for use immediately at compile time | yes
| :remove | Uninstalls the artifactory gem | no

Usage

```ruby
artifactory_rest_gem 'latest' do
  source '/my/local/gem/dl'
end
```
```ruby
artifactory_rest_gem '2.3.0'do
  :remove
end
```
## License and Authors

License: See the LICENSE file in this repository.

  * Author:: Ryan Larson (<ryan.mango.larson@gmail.com>)
  * Author:: Ben Jansen (<aogail@w007.org>)
