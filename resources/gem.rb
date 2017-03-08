property :version, String, name_property: true
property :source, String, required: false
default_action :install

action :install do
  chef_gem 'artifactory' do
    compile_time true
    version new_resource.version unless version == 'latest'
    source new_resource.source unless source.nil?
  end
end

action :remove do
  chef_gem 'artifactory' do
    action :remove
  end
end
