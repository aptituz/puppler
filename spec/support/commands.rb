require 'subprocess'

module Spec
  module Commands
    PUPPLER_EXE = File.expand_path('../../../bin/puppler', __FILE__)
    def puppler(*args)
      commandline = [PUPPLER_EXE] << args
      in_directory workdir do
        @output = Subprocess.check_output(commandline.flatten, stderr: STDOUT).split("\n")
      end
      @output
    end

    def run_in_workdir(*args)
      commandline = args.to_a
      in_directory workdir do
        @output = Subprocess.check_output(commandline.flatten, stderr: STDOUT).split("\n")
      end
    end

    def git(*args)
      commandline = ['git'] << args.map(&:to_s)
      Subprocess.check_output(commandline.flatten, stderr: STDOUT)
    end
  end
end