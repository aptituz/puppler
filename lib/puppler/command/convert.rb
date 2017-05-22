module Puppler
  class Command
    # puppler command: convert existing Shallowfile to puppetfile
    class Convert < Command
      include Puppler::Utils
      attr_reader :options

      def run(shallowfile)
        if File.exist?(options[:puppetfile])
          log_fatal("The specified Puppetfile `#{options[:puppetfile]}' already exists, will not overwrite it.")
        end
        shallowfile_data = YAML.safe_load(File.read(shallowfile))

        puppetfile_lines = []
        shallowfile_data['projects'].each do |modname, data|
          # FIXME: Add support for branch excludes?
          url = data.is_a?(Hash) ? data['url'] : data
          puppetfile_lines << "mod '#{modname}',\n" << "    :git => '#{url}'\n\n"
        end
        write_puppetfile(puppetfile_lines)
      end

      private

      def write_puppetfile(puppetfile_lines)
        File.open(options[:puppetfile], 'w') do |file|
          puppetfile_lines.each { |line| file.puts(line) }
        end
        log_info("Written Puppetfile to `#{options[:puppetfile]}'.")
      end
    end
  end
end
