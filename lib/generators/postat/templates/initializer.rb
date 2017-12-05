# frozen_string_literal: true

POSTAT_CONFIG = {
  guid: ENV['POSTAT_GUID'] || 'guid',
  username: ENV['POSTAT_USERNAME'] || 'username',
  password: ENV['POSTAT_PASSWORD'] || 'password',
  namespace: ENV['POSTAT_NAMESPACE'] || 'http://example.com/',
  wsdl: ENV['POSTAT_WSDL'] || 'http://example.com/soap?WSDL'
}

config_file = File.expand_path("#{Rails.root}/config/postat.yml", __FILE__)
if File.exist?(config_file)
  configs_from_file = YAML.safe_load(File.read(config_file))
  POSTAT_CONFIG.merge!(configs_from_file[Rails.env])
  POSTAT_CONFIG.symbolize_keys!
end
