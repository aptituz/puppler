require 'subprocess'
module Puppler
  class Git
    # represents a git bundle file and allows to get informations about it
    #
    # This class allows to query an existing git bundle for tags and branches or create a new bundle from an
    # existing source repository.
    #
    # It's meant to provide an interface to existing or to-be-created git bundles, although it makes use
    # of other classes (notably Puppler::Git::Refs) for the grunt work.
    class Bundle
      include Puppler::Utils::Git

      # @return [Puppler::Git::Refs]
      attr_accessor :refs
      attr_reader :path

      def initialize(name)
        @name = name
        @filename = name + '.bundle'
        @path     = Puppler.bundle_path.join(@filename)
        fetch_refs
      end

      # Creates a or updates this bundle from a repository
      #
      # This method creates (or updates an existing) bundle by calling `git bundle create`.
      def create_or_update_from_repository(repository_path)
        Dir.chdir(repository_path) do
          git %w[gc --aggressive], omit_output: true
          git(['bundle', 'create', path.to_s, '--all'], omit_output: true, quiet: false)
        end

        fetch_refs
      end

      # Checks if the bundle file exists on the file
      # @return [Boolean] t
      def exists?
        File.exist?(path)
      end

      # Checks if the refs contained in the bundle have changed since object initialisation
      # @return [Boolean] if the bundle
      def changed?
        return false if exists? && @old_refs.nil?
        @old_refs != @refs
      end

      # Returns the changes done to the bundle refs since object initialisation
      # @return [Hash]
      def changes
        return false if exists? && @old_refs.nil?
        @old_refs.diff(@refs)
      end

      # fetches the current refs in the git bundle by calling git bundle list-heads
      # and parsing the output
      #
      # makes use of Puppler::Git::Refs to parse the output of `bundle list-heads
      # @return [Hash]
      def fetch_refs
        if !exists?
          # create empty ref set, so that every ref becomes an addition after creating this bundle
          @refs = Puppler::Git::Refs.new('')
        else
          @old_refs = @refs
          @refs     = Puppler::Git::Refs.new(heads)
        end
      end

      private

      # Calls `git bundle list-heads` and returns the lines returned
      # @return [Array]
      def heads
        git(['bundle', 'list-heads', path.to_s], output: true, quiet: false).split("\n")
      end
    end
  end
end
