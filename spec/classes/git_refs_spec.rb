require 'spec_helper'

ref_lines_bundled_repo = <<-EOT
0bcf4bb16d386cd2d0499b5f9c75f8f170bff45b refs/heads/master
0bcf4bb16d386cd2d0499b5f9c75f8f170bff45b refs/heads/next
0bcf4bb16d386cd2d0499b5f9c75f8f170bff45b refs/tags/1.0.0
0bcf4bb16d386cd2d0499b5f9c75f8f170bff45b refs/tags/1.2.0
0bcf4bb16d386cd2d0499b5f9c75f8f170bff45b HEAD
EOT

ref_lines_bundled_repo_shallow_tags = <<-EOT
0bcf4bb16d386cd2d0499b5f9c75f8f170bff45b refs/heads/master
0bcf4bb16d386cd2d0499b5f9c75f8f170bff45b refs/heads/next
0bcf4bb16d386cd2d0499b5f9c75f8f170bff45b refs/heads/feature/test
0bcf4bb16d386cd2d0499b5f9c75f8f170bff45b refs/heads/tags/1.0.0
0bcf4bb16d386cd2d0499b5f9c75f8f170bff45b refs/heads/tags/1.2.0
0bcf4bb16d386cd2d0499b5f9c75f8f170bff45b HEAD
EOT


ref_lines_bundled_repo_shallow_tags_changed = <<-EOT
0bcf4bb16d386cd2d0499b5f9c75f8f170bffccc refs/heads/master
0bcf4bb16d386cd2d0499b5f9c75f8f170bffccc refs/heads/next
0bcf4bb16d386cd2d0499b5f9c75f8f170bffccc refs/heads/feature/new
0bcf4bb16d386cd2d0499b5f9c75f8f170bfffff refs/heads/tags/1.0.0
0bcf4bb16d386cd2d0499b5f9c75f8f170bff45b refs/heads/tags/1.3.0
0bcf4bb16d386cd2d0499b5f9c75f8f170bff45b HEAD
EOT

r10k_ref_lines = <<-EOT
28156cb899359d2847942bfb834fec01e382cca6 refs/heads/master
28156cb899359d2847942bfb834fec01e382cca6 refs/remotes/cache/master
f4fffd877cf2bc16173322a6d717cad229cdb8e5 refs/remotes/cache/next
28156cb899359d2847942bfb834fec01e382cca6 refs/remotes/origin/HEAD
28156cb899359d2847942bfb834fec01e382cca6 refs/remotes/origin/master
f4fffd877cf2bc16173322a6d717cad229cdb8e5 refs/remotes/origin/next
330f43d1d396d48e94cd734519e5fc662eb78947 refs/tags/1.0.0
330f43d1d396d48e94cd734519e5fc662eb78947 refs/tags/1.2.0
EOT

describe Puppler::Git::Refs do
  context "with the ref lines of a bundled repo" do
    subject { Puppler::Git::Refs.new(ref_lines_bundled_repo) }

    it "knows about branches" do
      expect(subject.branches).to include('heads/master', 'heads/next')
    end
    it "knows about tags" do
      expect(subject.tags).to include('tags/1.0.0')
    end
    it "ignores HEAD" do
      expect(subject.branches).not_to include('HEAD')
    end
  end

  context "with the ref lines of a bundled repo (shallowed tags)" do
    subject { Puppler::Git::Refs.new(ref_lines_bundled_repo_shallow_tags) }

    it "knows about branches" do
      expect(subject.branches).to include('heads/master')
    end
    it "knows about tags" do
      expect(subject.tags).to include('tags/1.0.0', 'tags/1.2.0')
    end
    it "ignores HEAD" do
      expect(subject.branches).not_to include('HEAD')
    end
  end


  context "with the ref lines of a r10k cloned repo" do
    subject { Puppler::Git::Refs.new(r10k_ref_lines) }

    it "knows about branches for remote origin" do
      expect(subject.branches('origin')).to include('remotes/origin/master')
    end
    it "knows about tags for remote origin" do
      expect(subject.tags).to include('tags/1.0.0', 'tags/1.2.0')
    end
    it "ignores HEAD even for remote origin" do
      expect(subject.branches('origin')).not_to include('remotes/origin/HEAD')
    end

    it "does not contain cache remotes" do
      expect(subject.branches('origin')).not_to include('remotes/cache/next', 'remotes/cache/master')
    end
  end

  context "when comparing one object with another" do
    before (:all) do
      @old = Puppler::Git::Refs.new(ref_lines_bundled_repo_shallow_tags)
      @new = Puppler::Git::Refs.new(ref_lines_bundled_repo_shallow_tags_changed)
    end

    subject { @old.diff(@new) }

    it {
      expect(@old).not_to eq(@new)
    }

    it { expect(subject).to be_kind_of(Hash) }
    it { expect(subject[:tags]).to include({ :added => ['tags/1.3.0'], :removed => ['tags/1.2.0'], :changed => ['tags/1.0.0' ]} ) }
    it { expect(subject[:branches]).to include({ :added => ['heads/feature/new'], :removed => ['heads/feature/test'], :changed => ['heads/master', 'heads/next' ]} ) }

  end

  context "when comparing to identical objects" do
    before (:all) do
      @old = Puppler::Git::Refs.new(ref_lines_bundled_repo_shallow_tags)
      @new = Puppler::Git::Refs.new(ref_lines_bundled_repo_shallow_tags)
    end

    it { expect(@old).to eq(@new) }
  end

end
