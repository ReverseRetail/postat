require File.expand_path('spec/spec_helper')

describe Postat do
  let(:config) { YAML.load_file('spec/config.yml') }
  let(:client) { Postat.new(config) }

  it 'has a VERSION' do
    Postat::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end

  describe :flush do
    it 'can do it' do
      client.flush(config[:cname], '/foo')
    end
  end
end
