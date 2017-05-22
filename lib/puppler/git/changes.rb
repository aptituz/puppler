module Puppler
  class Git
    # representing changes to a puppet module git repo, suitable for use in changelog generation
    class Changes
      attr_reader :modulename
      attr_reader :repo
      attr_reader :tags
      attr_reader :branches

      def initialize(modulename, repo)
        @modulename = modulename
        @repo = repo
        @tags = repo.bundle.changes[:tags]
        @branches = repo.bundle.changes[:branches]
      end

      def changed_tags_or_branches
        [tags[:changed], branches[:changed]].flatten.each_with_object({}) do |changed_ref, result|
          result[changed_ref.sub('heads/', '')] = repo.bundle.refs.resolve(changed_ref)
        end
      end

      def added_tags_and_branches
        [tags[:added], branches[:added]].flatten.map { |ref| ref.sub('heads/', '')}
      end

      def removed_tags_and_branches
        [tags[:removed], branches[:removed]].flatten.map { |ref| ref.sub('heads/', '')}
      end

      def summary
        summary = "Update #{modulename}: "
        summary << added_tags_and_branches.map { |ref| "+#{ref}" }.join(", ")
        summary << removed_tags_and_branches.map { |ref| "-#{ref}" }.join(", ")
        summary
      end

      def get_binding
        binding()
      end
    end
  end
end