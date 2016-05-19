Gem::Specification.new do |spec|
  spec.name          = 'ruby-crawler'
  spec.authors       = ['jaythomas']
  spec.email         = ['jay@gfax.ch']
  spec.homepage      = 'https://github.com/jaythomas/ruby-crawler'
  spec.license       = 'LGPL-3.0'

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'anemone', '>= 0.7.2'
  spec.add_runtime_dependency 'commander', '>= 4.4.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '>= 11.1.2'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'webmock', '>= 2.0.2'
end
