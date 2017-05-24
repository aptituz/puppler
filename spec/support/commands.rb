require 'subprocess'
require 'open3'

module Spec
  module Commands
    PUPPLER_EXE = File.expand_path('../../../bin/puppler', __FILE__)

    # this is basically because I found no better way to include stderr/stdout when a command execution fails
    def run_command(cmd)
      Open3.popen3(cmd.join(" ")) do |stdin, stdout, stderr, wait_thr|
        yield stdin, stdout, wait_thr if block_given?
        stdin.close

        @exitstatus = wait_thr && wait_thr.value.exitstatus
        @out = stdout.read.strip
        @err = stderr.read.strip
      end

      exception_message = <<-EOT
Executing command "#{cmd}" failed. Output of the failing command:

#{@out}
#{@err}

EOT
      raise RuntimeError.new(exception_message) unless @exitstatus == 0
      @out
    end

    def puppler(*args)
      commandline = [PUPPLER_EXE] << args
      in_directory workdir do
        @output = run_command(commandline.flatten).split("\n")
      end
      @output
    end

    def run_in_workdir(*args)
      commandline = args.to_a
      in_directory workdir do
        @output = run_command(commandline.flatten).split("\n")
      end
    end

    def git(*args)
      commandline = ['git'] << args.map(&:to_s)
      run_command(commandline.flatten)
    end
  end
end