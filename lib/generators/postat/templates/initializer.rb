# frozen_string_literal: true

config = {}
config_file = File.expand_path("#{Rails.root}/config/postat.yml", __FILE__)
if File.exist?(config_file)
  configs_from_file = YAML.safe_load(File.read(config_file))
  config.merge!(configs_from_file[Rails.env])
  config.symbolize_keys!
end
POSTAT_CONFIG = config
