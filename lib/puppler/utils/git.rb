module Puppler
  module Utils
    # Provides git command execution method
    module Git
      def git(arguments, options = {}, &block)
        argv = %w[git]

        argv << arguments
        argv << '-q' if options.fetch(:quiet, true)

        subprocess_options = {}
        subprocess_options[:stdin] = options.delete(:stdin)
        subprocess_options[:stderr] = options.delete(:stderr)
        subprocess_options[:cwd]    = options.delete(:cwd)
        subprocess_options[:stderr] = STDOUT if options[:omit_output]

        if options[:log_commandline]
          log_info("Runing command: #{argv.flatten}")
        end

        if options[:output] || options[:omit_output]
          Subprocess.check_output(argv.flatten, subprocess_options, &block)
        else
          Subprocess.check_call(argv.flatten, subprocess_options, &block)
        end
      end
    end
  end
end
