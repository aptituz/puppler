module Puppler
  class Command
    # puppler command: install puppet module from Puppetfile by calling r10k
    class Install < Command
      include Puppler::Utils
      attr_reader :options

      R10K_ARGUMENT_DEFAULTS = {
        puppetfile: 'Puppetfile',
        moduledir: 'modules'
      }.freeze

      def run
        unless File.exist?(options[:puppetfile])
          log_fatal("The specified Puppetfile `#{options[:puppetfile]}' does not exist.")
        end

        run_external_command(r10k_commandline)
      end

      private

      def r10k_commandline
        commandline = %w[r10k puppetfile install]
        # compatibility hack for r10k version on Debian jessie - only add parameters when set differently
        # since that r10k version does not yet support that (but we are running with default pathes anyway)
        %i[puppetfile moduledir].each do |option_name|
          unless options[option_name] == R10K_ARGUMENT_DEFAULTS[option_name]
            commandline << '--' + option_name.to_s << options[option_name]
          end
        end
        commandline
      end
    end
  end
end
