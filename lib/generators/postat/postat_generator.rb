# frozen_string_literal: true

require 'rails/generators/base'

class PostatGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc 'Copy the initializer for Postat'
  def copy_initializer_file
    copy_file 'initializer.rb', 'config/initializers/postat.rb'
  end

  desc 'Copy the yml for Postat'
  def copy_yml_files
    copy_file 'initializer.yml', 'config/postat.yml'
    copy_file 'initializer.yml', 'config/postat-example.yml'
  end

  desc 'Add yml to .gitignore'
  def add_to_gitignore
    append_to_file '.gitignore', 'config/postat.yml'
  end
end
