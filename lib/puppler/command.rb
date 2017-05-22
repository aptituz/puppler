module Puppler
  # Base class for puppler commands which represent actions a user can execute
  class Command
    include Puppler::Utils

    attr_reader :options

    def initialize(options)
      @options = options
      Puppler.configure_from_options(options)
    end
  end
end
