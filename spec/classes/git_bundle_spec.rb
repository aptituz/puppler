require 'puppler'

require 'spec_helper'

describe Puppler::Git::Bundle do
  before :all do
    FileUtils.remove_entry tmp('bundles') if File.exist?(tmp('bundles'))
    FileUtils.mkpath tmp('bundles')
    Puppler.bundle_path = tmp('bundles')
  end

  subject { Puppler::Git::Bundle.new('testmodule') }

  it { expect(subject).to respond_to(:refs) }
  it { expect(subject).to respond_to(:create_or_update_from_repository) }
  it { expect(subject).to respond_to(:exists?) }
  it { expect(subject).to respond_to(:changed?) }

  it { expect(subject.refs).to be_kind_of(Puppler::Git::Refs) }

  describe "with a non-existing bundle" do
    before :all do
      create_tag('dummymodule1', 'debian/1.0.1')
      push('dummymodule1')
    end

    subject { Puppler::Git::Bundle.new('dummymodule1') }

    it { expect(subject.exists?).to be_falsey }

    it "creates a bundle successfully" do
      expect(subject.create_or_update_from_repository(tmp('repos').join('dummymodule1.git'))).to be_truthy
      expect(subject.exists?).to be_truthy
      expect(subject.changed?).to be_truthy
    end
  end

  describe "with an existing bundle" do
    before :all do

      create_tag('dummymodule2', '1.0.0')
      create_tag('dummymodule2', '2.0.0')

      push('dummymodule2')

      Puppler::Git::Bundle.new('dummymodule2').create_or_update_from_repository(
          tmp('repos').join('dummymodule2.git')
      )

      @bundle = Puppler::Git::Bundle.new('dummymodule2')
      @bundle.create_or_update_from_repository(
          tmp('repos').join('dummymodule2.git')
      )

      @bundle.create_or_update_from_repository( tmp('repos').join('dummymodule2.git'))
    end

    %w[master next].each do |branch|
      it "knows about existing branch '#{branch}'" do
        expect(@bundle.refs.branches).to include('heads/' + branch)
      end
    end
    %w[master next].each do |branch|
      it "does not list  previous existing branch '#{branch}' as changed" do
        expect(@bundle.changes[:branches][:added]).not_to include(branch)
        expect(@bundle.changes[:branches][:removed]).not_to include(branch)
      end
    end

    it "knows about existing tag: 'tags/1.0.0'" do
      expect(@bundle.refs.tags).to include('tags/1.0.0')
    end

    it "tells that the bundle has not changed" do
      expect(@bundle.changed?).to be_falsey
    end

    %w[master next].each do |branch|
      it "does not list  previous existing branch '#{branch}' as changed" do
        expect(@bundle.changes[:branches][:added]).not_to include(branch)
        expect(@bundle.changes[:branches][:removed]).not_to include(branch)
      end
    end

    describe "when adding another tag" do
      before :all do
        create_branch('dummymodule2', 'feature/new')
        push('dummymodule2')
        @bundle.create_or_update_from_repository(tmp('repos').join('dummymodule2.git'))
      end

      it "tells that the bundle has changed" do
        expect(@bundle.changed?).to be_truthy
      end

      it "includes the new branch in the changelist" do
        expect(@bundle.changes[:branches][:added]).to include('heads/feature/new')
      end
    end
  end
end