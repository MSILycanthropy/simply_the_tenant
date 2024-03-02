require_relative "lib/simply_the_tenant/version"

Gem::Specification.new do |spec|
  spec.name        = "simply_the_tenant"
  spec.version     = SimplyTheTenant::VERSION
  spec.authors     = ["Ethan Kircher"]
  spec.email       = ["ethanmichaelk@gmail.com"]
  spec.homepage    = "https://github.com/MSILycanthropy/simply_the_tenant"
  spec.summary     = "A simple multi-tenant solution for Rails."
  spec.description = "A simple multi-tenant solution for Rails."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.3.2"
end
