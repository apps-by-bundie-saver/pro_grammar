
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pro_grammar/version"

Gem::Specification.new do |spec|
  spec.name          = "pro_grammar"
  spec.version       = ProGrammar::VERSION
  spec.authors       = ["Bundie the Bunny"]
  spec.email         = ["bundiethebunny@bundiesaver.com"]

  spec.summary       = %q{The sensible programmers' tool for easy trace-logging, resolution logger, and development note-taking (brought to you by Bundie Saver LLC)}
  spec.description   = %q{ProGrammar is the development logging tool that allows developers to keep track and log their development steps as they debug errors. As a developer, you will, no doubt, encounter countless errors and attempts at resolving those errors; it becomes a multi-step process in troubleshooting those errors, and ProGrammar helps you log all of your steps into a text generated document which is succinct and easy-to-read as developer notes.}
  spec.homepage      = "https://github.com/apps-by-bundie-saver/pro_grammar"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "http://mygemserver.com"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/apps-by-bundie-saver/pro_grammar"
    spec.metadata["changelog_uri"] = "https://github.com/apps-by-bundie-saver/pro_grammar/wiki/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
