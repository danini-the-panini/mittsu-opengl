# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mittsu/opengl/version'

Gem::Specification.new do |spec|
  spec.name          = "mittsu-opengl"
  spec.version       = Mittsu::OpenGL::VERSION
  spec.authors       = ["Danielle Smith"]
  spec.email         = ["danini@hey.com"]

  spec.summary       = %q{OpenGL renderer for Mittsu}
  spec.description   = %q{OpenGL 3 renderer for Mittsu using GLFW for context creation}
  spec.homepage      = "https://github.com/danini-the-panini/mittsu"
  spec.license       = "MIT"
  spec.metadata = {
    "bug_tracker" => "https://github.com/danini-the-panini/mittsu/issues"
  }

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{(^(test|examples)/|\.sh$)}) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.6.0'
  spec.requirements << 'OpenGL 3.3+ capable hardware and drivers'

  spec.add_runtime_dependency 'opengl-bindings2'
  spec.add_runtime_dependency 'fiddle', '~> 1.0'
  spec.add_runtime_dependency 'mittsu', '~> 0.5.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-reporters', '~> 1.7'
  spec.add_development_dependency 'benchmark-ips', '~> 2.14'
  spec.add_development_dependency 'simplecov', '0.17.1'
end
