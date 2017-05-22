describe 'puppler init command' do
  it "runs without errors" do
    status = puppler 'init', '--package-name', 'foobar'
    expect(status).to be_truthy
  end

  %w[rules install control source/format].each do |fname|
    it "creates file debian/#{fname}" do
      file_path = workdir.join("debian", fname)

      expect(File).to exist(file_path)
    end
  end

  it "debian/install has expected content" do
    expect(File.read(workdir.join("debian/install"))).to include("bundles/*.bundle /usr/share/puppet/foobar/")
  end
end