lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name          = 'postat'
  s.version       = '0.0.2'
  s.authors       = ['Yves Goizet','Owen Peredo']
  s.email         = ['it@buddyandselly.com']
  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  s.homepage      = 'https://github.com/ReverseRetail/postat'
  s.license       = 'MIT'
  s.require_paths = ['lib']
  s.summary       = 'Wrapper for PostAT SOAP Api'
  s.test_files    = ['spec/postat_spec.rb', 'spec/spec_helper.rb']

  if s.respond_to? :specification_version
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
      s.add_runtime_dependency('savon', '~> 2.10')
    else
      s.add_dependency('savon', '~> 2.10')
    end
  else
    s.add_dependency('savon', '~> 2.10')
  end
end
