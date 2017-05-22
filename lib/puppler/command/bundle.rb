require 'erb'
require 'tempfile'

module Puppler
  class Command
    # puppler command: bundle puppet modules in the current project
    # calls the install command if no module_directories are found
    class Bundle < Command
      include Puppler::Utils
      include Puppler::Utils::Git

      attr_reader :options

      def run
        unless module_directories.any?
          Puppler::Command::Install.new(options).run
        end

        check_working_directory
        process_module_directories
      end

      def check_working_directory
        unless File.exist?(Puppler.rootdir.join(".git"))
          log_fatal "Working directory is not yet a git repository: please run `puppler init` or initialize git yourself."
        end
      end

      def process_module_directories
        module_directories.each do |moduledir|
          puppet_module = Puppler::PuppetModule.new(moduledir)

          log_info("Processing module '#{puppet_module.name}'")
          puppet_module.git.checkout_orphan_clones

          create_module_bundle(File.basename(moduledir), puppet_module)
        end
      end

      # Creates git bundle of the module with all branches and tags shallow-cloned
      def create_module_bundle(_bundle_name, puppet_module)
        log_info("Creating/Updating bundle for module '#{puppet_module.name}' in '#{puppet_module.git.bundle.path}'")

        puppet_module.git.create_or_update_bundle
        if puppet_module.git.bundle.changed?
          log_info 'Bundle changed.'
          commit_module(puppet_module)
        else
          log_info 'Bundle has no changes.'
        end
      end

      # Commits the given puppet_module, using a changelog generated from the ref changes
      def commit_module(puppet_module)
        changes = Puppler::Git::Changes.new(puppet_module.name, puppet_module.git)
        commit_message = changelog(changes)
        unless options[:commit]
          log_info "Not committing the following changes as requested: '#{changes.summary}'"
          return
        end
        File.open(Puppler.workdir.join("commit_msg"), 'w') do |file|
          file.write(commit_message)
        end

        git ['add', puppet_module.git.bundle.path.to_s], quiet: false, log_commandline: true
        git ['commit', '--file', Puppler.workdir.join("commit_msg").to_s, puppet_module.git.bundle.path.to_s], quiet: false, log_commandline: true
      end

      # Generate a changelog entry
      def changelog(changes)
        template = File.join(Puppler::CLI::source_root, "templates", 'changelog.erb')
        renderer = ERB.new(File.read(template), nil, '-')
        renderer.result(changes.get_binding)
      end

      def module_directories
        Dir.glob("#{options[:moduledir]}/*").keep_if { |directory_entry| File.directory?(directory_entry) }
      end
    end
  end
end
