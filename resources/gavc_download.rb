actions :download
default_action :download

attribute :path, :name_attribute => true, :kind_of => String, :required => true
attribute :endpoint, :kind_of => String, :required => true
attribute :username, :kind_of => String, :required => false
attribute :password, :kind_of => String, :required => false
attribute :group_id, :kind_of => String, :required => true
attribute :artifact_id, :kind_of => String, :required => true
attribute :version, :kind_of => String, :required => true
attribute :classifier, :kind_of => String, :required => false, :default => nil
attribute :packaging, :kind_of => String, :required => true, :default => nil
attribute :repository_keys, :kind_of => Array, :required => true

def to_s
  "group: #{group_id}, artifact id: #{artifact_id}, version: #{version}, classifier: #{classifier}, packaging: #{packaging}, repository_keys: #{repository_keys.inspect}"
end
