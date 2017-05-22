# frozen_string_literal: true

require 'puppler/version'
require 'puppler/utils'
require 'puppler/utils/git'
require 'puppler/git/repository'
require 'puppler/git/bundle'
require 'puppler/git/changes'
require 'puppler/git/refs'
require 'puppler/puppet_module'
require 'puppler/command'

# Puppler application class - mainly storing configuration data for runtime use
module Puppler
  class << self
    attr_accessor :rootdir
    attr_accessor :workdir
    attr_accessor :bundle_path

    def configure_from_options(options)
      rootdir_from_puppetfile_path(File.absolute_path(options[:puppetfile]))
      Puppler.workdir = Puppler.rootdir.join('.puppler.workdir')
      Puppler.bundle_path = Puppler.rootdir.join('bundles')

      if File.exist?(Puppler.workdir)
        FileUtils.remove_entry_secure(Puppler.workdir)
      end
      FileUtils.mkpath(Puppler.workdir)
      FileUtils.mkpath(Puppler.bundle_path)
    end

    def rootdir_from_puppetfile_path(puppetfile_path)
      @rootdir = Pathname.new(File.dirname(puppetfile_path))
    end
  end
end

require 'puppler/command/install'
require 'puppler/command/bundle'
require 'puppler/command/convert'
require 'puppler/cli'
