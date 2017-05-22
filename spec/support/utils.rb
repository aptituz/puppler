module Spec
  module Utils
    def reset!
      FileUtils.remove_entry(tmp('repos')) if File.exist?(tmp('repos'))
    end
  end
end