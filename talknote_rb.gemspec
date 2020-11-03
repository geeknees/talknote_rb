require_relative 'lib/talknote/version'

Gem::Specification.new do |spec|
  spec.name          = "talknote_rb"
  spec.version       = Talknote::VERSION
  spec.authors       = ["Masumi Kawasaki"]
  spec.email         = ["mkawasaki@sbihg.co.jp"]

  spec.summary       = %q{Talknote API Client.}
  spec.description   = %q{Talknote API Wrapper written in ruby.}
  spec.homepage      = "https://github.com/geeknees/talknote_rb"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/geeknees/talknote_rb"
  spec.metadata["changelog_uri"] = "https://github.com/geeknees/talknote_rb"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'oauth2'
end
