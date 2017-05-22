module Puppler
  class Git
    # representation of a set of refs in a git-bundle or git repository
    #
    # provides access to the list of tags and branches, allows resolving ref names to commits
    # and allows diffing to ref sets
    class Refs
      def initialize(ref_lines)
        @refs = parse(ref_lines)
      end

      # Returns the tags in this set of refs
      #
      # This methods returns all tags in the ref set represented by this object.
      #
      # @return [Array]
      def tags
        tags = @refs.fetch(:tags)
        tags = tags.map { |tag| tag.sub('heads/', '') }
        tags
      end

      # Resolve the given ref to its corresponding commit
      #
      # @return [String]
      def resolve(ref)
        @refs.fetch(:ref_map).fetch(ref)
      end

      # Returns the branches in this set of refs
      #
      # This methods returns all branches in the ref set represented by this object. If the optional remote argument
      # is given, the output is filtered for the given remote.
      #
      # @return [Array]
      def branches(remote = nil)
        branches = @refs.fetch(:branches)
        unless remote.nil?
          branches.keep_if { |branch| branch.start_with?("remotes/#{remote}") }
        end
        branches
      end

      # Parse input lines for refs and their commits
      #
      # This method expects it's input in the form as it's given by `git show-ref`` or ``git bundle list-heads``
      # and returns a hash of the contained tags, branches and a ref_map for easier lookup of commit ids.
      #
      # @return [Hash]
      # rubocop:disable Metrics/MethodLength
      def parse(lines)
        lines = lines.split("\n") unless lines.is_a?(Array)

        tags     = []
        branches = []
        ref_map  = {}

        lines.each do |line|
          commit, refname = line.split(' ')

          refname.sub!('refs/', '')
          if tag?(refname)
            refname.sub!('heads/', '')
            tags << refname
          elsif branch?(refname)
            branches << refname
          end
          ref_map[refname] = commit
        end

        { tags: tags, branches: branches, ref_map: ref_map, lines: lines }
      end

      def ==(other)
        changes = diff(other)
        changes == { tags: { added: [], removed: [], changed: [] }, branches: { added: [], removed: [], changed: [] } }
      end

      # Compare this Refs object with another Refs object and return differences
      #
      # @return [Hash] added, removed or changed tags and branches
      def diff(new)
        raise 'expecting object of kind Pupper::Refs' unless new.is_a?(Puppler::Git::Refs)

        changes = {
          tags:     { added: new.tags - tags,         removed: tags - new.tags },
          branches: { added: new.branches - branches, removed: branches - new.branches }
        }

        tags_in_both      = new.tags & tags
        branches_in_both  = new.branches & branches
        changes[:tags][:changed]      = tags_in_both.reject { |tag| new.resolve(tag) == resolve(tag) }
        changes[:branches][:changed]  = branches_in_both.reject { |branch| new.resolve(branch) == resolve(branch) }

        changes
      end
      # rubocop:enable Metrics/MethodLength

      private

      # Tests if the given ref is a branch
      def branch?(name)
        return false if name.end_with?('HEAD')
        return true if name.start_with?('heads/', 'remotes/')
      end

      # Tests if the given ref is a tag or a branch created from a tag (e.g. a shallow-clone of a tag)
      def tag?(name)
        # this is not exactly correct, but when we shallow clone tags they become branches and we still want them
        # to be shown up as tag
        true if name.start_with?('tags/', 'heads/tags/', 'remotes/tags/')
      end
    end
  end
end
