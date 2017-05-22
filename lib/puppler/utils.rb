# frozen_string_literal: true

require 'rainbow'
require 'subprocess'

module Puppler
  # utility methods for logging and command execution
  module Utils
    def log_info(message)
      puts Rainbow(message).color(:blue)
    end

    def log_fatal(message)
      puts Rainbow(message).color(:red)
      exit 1
    end

    # @return [Process::Status]
    def run_external_command(arguments, log_commandline: true)
      log_info("Running external command: #{arguments.inspect}") if log_commandline
      Subprocess.check_call arguments
    end
  end
end
