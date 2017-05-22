require 'spec_helper'

describe 'puppler install command' do
  describe "with only Puppetfile in workdir" do
    before :all do
      puppler 'install'
    end

    it "runs without errors" do
      expect(@output).to be
    end

    it "creates modules directory" do
      expect(File).to exist('modules')
    end

    %w[dummymodule1 dummymodule2].each do |mod|
      it "cloned module #{mod}" do
        expect(File).to exist("modules/#{mod}")
        expect(File).to exist("modules/#{mod}/metadata.json")
      end
    end
  end

  describe "with no Puppetfile in workdir" do
    before :all do
      File.delete (workdir.join('Puppetfile'))
    end
  end

end