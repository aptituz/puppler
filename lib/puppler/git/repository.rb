# frozen_string_literal: true

require 'fileutils'

module Puppler
  class Git
    # class encapsulating interaction with git repository of a puppet module
    #
    # when initialized with the path to a module repository it initializes two directories
    #
    # - a working copy of the module repo as source repo
    # - a bare repository as target repository
    #
    # it then provides methods for shallow-cloning tags and branches and creating a bundle of the target repo
    class Repository
      include Puppler::Utils
      include Puppler::Utils::Git

      # the git bundle for this repository
      # @return [Puppler::Git::Bundle]
      attr_accessor :bundle

      def initialize(path)
        @path = File.absolute_path(path)

        name = File.basename(path)
        @source_repo = Puppler.workdir.join(name).to_s
        @target_repo = Puppler.workdir.join(name + '.git').to_s
        @bundle      = Puppler::Git::Bundle.new(name)

        # ensure clean state before cloning
        cleanup

        # move the r10k created repo, because r10k does not like messing with it's repos
        FileUtils.mv(@path, @source_repo)
        git %w[init --bare] << @target_repo, quiet: true
      end

      # processes all refs in the source repo and pushes orphan clones of them to the target repository
      def checkout_orphan_clones
        Dir.chdir(@source_repo) do
          git %w[remote add target] << @target_repo, quiet: false

          log_info("Found the following refs: #{source_refs.keys.join(' ')}")
          source_refs.each do |name, commit|
            name = name.gsub('origin/', '')
            shallow_name = "_git_shallow/#{name}"
            git ['checkout', '--orphan', shallow_name, commit]
            recreate_commit(commit)

            git ['push', '--force', 'target', "#{shallow_name}:#{name}"]
          end
        end
      end

      # Recreates a commit from a given commit hash
      #
      # Uses the previous commit author information to set committer and committer-date to ensure hash being stable
      # on subsequent runs
      def recreate_commit(commit)
        original_env = ENV.to_hash
        begin
          ENV['GIT_COMMITTER_DATE'] = git(['log', "--pretty=format:'%ad'", '-1', commit], output: true, quiet: false).to_s
          ENV['GIT_COMMITTER_NAME']  = git(['log', "--pretty=format:'%an'", '-1', commit], output: true, quiet: false).to_s
          ENV['GIT_COMMITTER_EMAIL'] = git(['log', "--pretty=format:'%ae'", '-1', commit], output: true, quiet: false).to_s
          git %w[commit -C] << commit
        ensure
          ENV.update(original_env)
        end
      end

      def create_or_update_bundle
        @bundle.create_or_update_from_repository(@target_repo)
      end

      # removes the repository created during initializing
      def cleanup
        FileUtils.rm_r(@target_repo) if File.exist?(@target_repo)
      end

      # obtain a hash of tags and branches in the source repository with their full refname and commit
      # filters branches for a list of wanted branches (currently master, next)
      #
      # @return [Hash] filtered ref list with refname and commit
      def source_refs
        source_refs = {}
        git(['show-ref'], output: true, quiet: false).split("\n").each do |line|
          commit, name = line.split(' ')

          name.sub!('refs/', '')
          name.sub!('remotes/', '')

          # we are only interested in tags and branches
          next if !name.start_with?('origin/') && !name.start_with?('tags/')

          # FIXME: Should be a configurable filter
          next if name =~ /origin/ && name !~ %r{origin/(master|next)}

          source_refs[name] = commit
        end
        source_refs
      end
    end
  end
end
