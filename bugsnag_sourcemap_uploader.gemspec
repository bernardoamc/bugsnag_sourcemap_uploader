# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bugsnag_sourcemap_uploader/version'

Gem::Specification.new do |spec|
  spec.name          = 'bugsnag_sourcemap_uploader'
  spec.version       = BugsnagSourcemapUploader::VERSION
  spec.authors       = ['Bernardo Chaves']
  spec.email         = ['bernardo.amc@gmail.com']

  spec.summary       = 'Upload sourcemaps to Bugsnag in parallel.'
  spec.homepage      = 'https://rubygems.org/gems/bugsnag_sourcemap_uploader'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'concurrent-ruby', '~> 1.1.4'
  spec.add_dependency 'httparty', '~> 0.17.0'
end
