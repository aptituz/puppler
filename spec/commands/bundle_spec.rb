require 'spec_helper'

describe "puppler bundle command" do
  describe 'with some very basic modules' do
    before :all do

      puppler 'bundle'
    end

    it "runs without errors" do
      expect(@output).to be_truthy
    end

    %w[dummymodule1 dummymodule2].each do |mod|
      it "creates a bundle file for module #{mod}" do
        expect(File).to exist("#{workdir}/bundles/#{mod}.bundle")
      end
      it "indicates bundle creation in output" do
        expect(@output).to include "Processing module '#{mod}'"
      end
    end
  end

  describe 'with a module with some tags and branches' do
    before(:all) do
      # reset!
      write_puppetfile('dummymodule1')

      create_tag('dummymodule1', 'debian/1.0.1')
      create_tag('dummymodule1', 'debian/1.0.2')
      push('dummymodule1')
      # puts "Push it all"
      puppler 'install'
      puppler 'bundle'
    end

    subject { puppler 'bundle' }

    it "tells to have found the tag refs" do
      expect(subject.join("\n")).to match %r{tags/debian/.*1\.0\.1.*}
      expect(subject.join("\n")).to match %r{tags/debian/.*1\.0\.2.*}
    end


    it "tells to have found the branch refs" do
       expect(subject.join("\n")).to match %r{origin/master}
       expect(subject.join("\n")).to match %r{origin/next}
    end

    it "included the tags in the bundle" do
       run_in_workdir 'git', 'bundle', 'list-heads', "bundles/dummymodule1.bundle"

       expect(@output.join("\n")).to match  %r{tags/debian/.*1\.0\.1.*}
       expect(@output.join("\n")).to match  %r{tags/debian/.*1\.0\.2.*}
    end

    it "included the branches in the bundle" do
       run_in_workdir 'git', 'bundle', 'list-heads', "bundles/dummymodule1.bundle"

        expect(@output.join("\n")).to match %r{master}
       expect(@output.join("\n")).to match %r{next}
     end

    it "excluded the feature branches in the bundle" do
      run_in_workdir 'git', 'bundle', 'list-heads', "bundles/dummymodule1.bundle"
      expect(@output.join("\n")).not_to match %r{feature/fubbel}
    end
  end


end

