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

## License and Authors

License: See the LICENSE file in this repository.

  * Author:: Ryan Larson (<ryan.mango.larson@gmail.com>)
  * Author:: Ben Jansen (<aogail@w007.org>)
