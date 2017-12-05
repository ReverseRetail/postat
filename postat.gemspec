lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name          = 'postat'
  s.version       = '0.0.1'
  s.authors       = ['Datyv']
  s.email         = ['yvesgoizet@gmail.com']
  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  s.homepage      = 'https://github.com/Datyv/postat'
  s.license       = 'MIT'
  s.require_paths = ['lib']
  s.summary       = 'Wrapper for Rylos SOAP Api for PostAt'
  s.test_files    = ['spec/post_at_spec.rb', 'spec/spec_helper.rb']

  if s.respond_to? :specification_version
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
      s.add_runtime_dependency('savon', ['~> 2.10.0'])
    else
      s.add_dependency('savon', ['~> 2.10.0'])
    end
  else
    s.add_dependency('savon', ['~> 2.10.0'])
  end
end
