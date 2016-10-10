# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "snazz"
  spec.version       = "0.0.1"
  spec.authors       = ["Zach Pendleton", "ddorman@instructure.com"]
  spec.email         = ["zachp@instructure.com", "ddorman@instructure.com"]

  spec.summary       = %q{Extensions to Sidekiq to support rate-limited, sequential, and periodic jobs}

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sidekiq", "~> 4.0"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "redis", "~> 3.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
