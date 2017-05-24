require 'fileutils'
require 'json'

module Spec
  module Builders

    def write_puppetfile(*modules)
      repo_base = tmp('repos')
      File.open(workdir.join('Puppetfile'), 'w') do |p|
        modules.each do |module_name|
          p.write <<EOT
mod '#{module_name}', :git => 'file://#{repo_base}/#{module_name}.git'
EOT
        end
      end
    end

    def build_puppet_modules(*modules)
      modules.each { |m| build_puppet_module(m) }
    end

    def get_repo_name(name)
      working_copy_dir = tmp('repos', name)
      repo_dir = tmp('repos', name + ".git")
      [working_copy_dir, repo_dir]
    end

    def build_puppet_module(name)
      working_copy_path = tmp('repos', name)
      bare_repo_path    = tmp('repos', name + ".git")

      metadata = JSON.parse(File.read(fixtures('metadata.json')))
      metadata['name'] = name
      metadata['version'] = '1.0.0'

      return if File.exist?(bare_repo_path)

      git 'init', '--bare', bare_repo_path
      git 'clone', bare_repo_path, working_copy_path

      File.open(working_copy_path.join("metadata.json"), 'w') { |f| f.write metadata.to_s }

      in_directory working_copy_path do
        git 'add', 'metadata.json'
        git 'commit', '-m', "'Initial commit'"

        git 'checkout', '-b', 'next'
        File.open('testfile', 'w') { |f| f.write("next") }
        git 'add', '-A'

        git 'commit', '-m', "'Next commit'"

        git 'push', '--mirror', '-u', 'origin'
        git 'push'
      end
    end

    def create_tag(module_name, tag_name)
      (working_copy_dir, repodir) = get_repo_name(module_name)

      in_directory working_copy_dir do
        git 'checkout', 'master'
        File.open("testfile", 'w') { |f| f.write tag_name }
        git 'add', 'testfile'
        git 'commit', '-m', "'Change something'"
        git 'tag', tag_name
      end
    end

    def remove_tag(module_name, tag_name)
      (working_copy_dir, repodir) = get_repo_name(module_name)
      in_directory working_copy_dir do
        git 'tag', '-d', tag_name
        git 'push', 'origin', ":refs/tags/#{tag_name}"
      end
    end

    def create_branch(module_name, branch_name)
      (working_copy_dir, repodir) = get_repo_name(module_name)

      File.open(working_copy_dir.join("testfile"), 'w') { |f| f.write branch_name }
      in_directory working_copy_dir do
        git 'branch', branch_name
        git 'checkout', branch_name, '-q'
        git 'add', 'testfile'
        git 'commit', '-m', "'Change something'"
      end
    end

    def remove_branch(module_name, branch_name)
      (working_copy_dir, repodir) = get_repo_name(module_name)

      in_directory working_copy_dir do
        git 'checkout', 'master'
        git 'branch', '-D', branch_name
        git 'push', 'origin', ":#{branch_name}"
      end
    end

    def push(module_name)
      (working_copy_dir, repodir) = get_repo_name(module_name)

      in_directory working_copy_dir do
        git 'push', '--all'
        git 'push', '--tags'
      end
    end
  end
end