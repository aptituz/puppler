# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'
require 'json'

module Puppler
  # represents a puppet module and provides method to fetch informations and interact with the repository it's stored in
  class PuppetModule
    include Puppler::Utils

    # @return [Puppler::Git] the object representing the git repository, where the module is stored
    attr_reader :git

    # @return [String] absolute path to the module directory
    attr_reader :path

    def initialize(moduledir)
      @path = File.absolute_path(moduledir)

      if File.exist?(moduledir + '/.git')
        @git = Puppler::Git::Repository.new(moduledir)
      else
        log_fatal("Module '#{name}' does not seem to be a git directory (currently required by puppler)")
      end
    end

    def metadata
      metadata_file_path = File.join(path, 'metadata.json')
      begin
        JSON.parse(File.read(metadata_file_path))
      rescue
        # we still have modules without metadata.json, so we return a empty hash in this case
        # and fall back to other information sources in this case
        return {}
      end
    end

    # Returns the (full) modulename
    def name
      modulename = metadata['name'] || File.basename(path)
      modulename.sub('-', '/')
    end
  end
end
