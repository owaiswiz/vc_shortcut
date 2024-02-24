require_relative "lib/vc_shortcut/version"

Gem::Specification.new do |spec|
  spec.name        = "vc_shortcut"
  spec.version     = VcShortcut::VERSION
  spec.authors     = ["Owais"]
  spec.email       = ["owaiswiz@gmail.com"]
  spec.homepage    = "https://github.com/owaiswiz/vc_shortcut"
  spec.summary     = "A simpler and less verbose-y way to render view_components"
  spec.description = "A simpler and less verbose-y way to render view_components"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/owaiswiz/vc_shortcut"
  spec.metadata["changelog_uri"] = "https://github.com/owaiswiz/vc_shortcut/releases"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6.1"
end
