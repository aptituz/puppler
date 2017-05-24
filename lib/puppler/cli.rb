# frozen_string_literal: true

require 'thor'
require 'yaml'

module Puppler
  # The face of puppler - command line interface, realized with thor
  # (https://github.com/erikhuda/thor)
  #
  # This is used by the `bin/puppler` executable. all public methods are commands
  # available to the user.
  class CLI < Thor
    include Thor::Actions
    include Puppler::Utils
    include Puppler::Utils::Git

    default_task :bundle

    class_option :puppetfile, default: 'Puppetfile'
    class_option :moduledir, default: 'modules'
    class_option :commit, :type => :boolean, default: true

    desc 'install', 'Install modules from puppetfile to moduledir'
    def install
      Puppler::Command::Install.new(options).run
    end

    desc 'bundle', 'Create bundles from all modules in moduledir'
    def bundle
      Puppler::Command::Bundle.new(options).run
    end

    desc 'convert SHALLOWFILE', 'Convert the given Shallowfile into puppetfile format'
    def convert(shallowfile)
      Puppler::Command::Convert.new(options).run(shallowfile)
    end

    # Template files used for debian packaging files when used as a generator
    TEMPLATE_FILES = {
      'rules.tt' => '%s/rules',
      'install.tt'  => '%s/install',
      'control.tt'  => '%s/control',
      'postinst.tt' => '%s/postinst'
    }.freeze

    desc 'init', 'Initialize packaging files for bundled modules'
    method_option :debian_directory, default: 'debian'
    method_option :package_name, required: true
    def init
      config = options.dup
      TEMPLATE_FILES.each do |template, destination_pattern|
        destination_file = format(destination_pattern, options[:debian_directory])
        template(File.join('templates', template), destination_file, config)
      end
      template(File.join('templates', 'CONTRIBUTING.md'), 'CONTRIBUTING.md', config)
      template(File.join('templates', 'Gemfile'), 'Gemfile', config)

      create_file("#{config[:debian_directory]}/source/format", '3.0 (native)')
      create_file("#{config[:debian_directory]}/compat", '9')
      create_file(".gitignore", ".puppler.workdir\nmodules\n")
    end

    # Method needed for generator actions (init) to know where to find templates
    def self.source_root
      File.expand_path(File.dirname(__FILE__) + '/../../')
    end
  end
end
