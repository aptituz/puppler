require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'puppler/version'
require 'bundler'

RSpec::Core::RakeTask.new(:spec)

task default: :test

desc 'run dch with appropriate arguments, even for updated gem version'
task :dch do
  puppler_version = Puppler::VERSION
  debian_version = `dpkg-parsechangelog -SVersion`
  if Gem::Version.new(puppler_version) > Gem::Version.new(debian_version)
    sh "dch -v#{puppler_version}"
  else
    sh 'dch'
  end
end
