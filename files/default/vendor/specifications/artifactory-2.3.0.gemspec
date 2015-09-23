# -*- encoding: utf-8 -*-
# stub: artifactory 2.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "artifactory"
  s.version = "2.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Seth Vargo"]
  s.date = "2015-08-04"
  s.description = "A Ruby client for Artifactory"
  s.email = "sethvargo@gmail.com"
  s.homepage = "https://github.com/opscode/artifactory-client"
  s.licenses = ["Apache 2.0"]
  s.rubygems_version = "2.4.8"
  s.summary = "Artifactory is a simple, lightweight Ruby client for interacting with the Artifactory and Artifactory Pro APIs."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
