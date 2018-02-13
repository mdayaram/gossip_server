
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gossip_server/version"

Gem::Specification.new do |spec|
  spec.name          = "gossip_server"
  spec.version       = GossipServer::VERSION
  spec.authors       = ["Manoj Dayaram"]
  spec.email         = ["m@noj.cc"]

  spec.summary       = %q{A gossip server for favorite books.}
  spec.description   = %q{Implements the gossip protocol for favorite books.}
  spec.homepage      = "https://github.com/mdayaram/gossip_server"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra"
  spec.add_dependency "http"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
