require_relative 'lib/dsl_evaluator/version'

Gem::Specification.new do |spec|
  spec.name          = "dsl_evaluator"
  spec.version       = DslEvaluator::VERSION
  spec.authors       = ["Tung Nguyen"]
  spec.email         = ["tongueroo@gmail.com"]

  spec.summary       = "DSL evaluation library. It produces a human-friendly backtrace error"
  spec.homepage      = "https://github.com/tongueroo/dsl_evaluator"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "memoist"
  spec.add_dependency "rainbow"
  spec.add_dependency "zeitwerk"
end
