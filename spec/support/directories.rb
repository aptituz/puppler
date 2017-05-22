require 'pathname'

module Spec
  module Directories
    def root
      @root ||= Pathname.new(File.expand_path("../../..", __FILE__))
    end

    def tmp(*path)
      root.join("tmp", *path)
    end

    def workdir
      @workdir ||= tmp.join('workdir')
    end

    def fixtures(*path)
      root.join('spec', 'fixtures', *path)
    end

    def in_directory(directory)
      FileUtils.mkdir_p(directory)
      Dir.chdir(directory) { yield }
    end
  end
end