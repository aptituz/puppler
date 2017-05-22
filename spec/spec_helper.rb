require 'puppler'

Dir["#{File.expand_path("../support", __FILE__)}/*.rb"].each do |file|
  require file
end


RSpec.configure do |config|
  config.include Spec::Utils
  config.include Spec::Directories
  config.include Spec::Builders
  config.include Spec::Commands

  original_pwd = Dir.pwd

  config.before :all do
    reset!
    FileUtils.mkpath(workdir)

    build_puppet_modules('dummymodule1', 'dummymodule2', 'dummymodule3')
    write_puppetfile('dummymodule1', 'dummymodule2')
  end

  config.before :each do
    Dir.chdir(workdir)
  end

  config.after :each do |example|
    Dir.chdir(original_pwd)
  end
end
