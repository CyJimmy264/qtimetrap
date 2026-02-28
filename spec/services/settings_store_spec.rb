# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe QTimetrap::Services::SettingsStore do
  around do |example|
    Dir.mktmpdir do |dir|
      @tmpdir = dir
      example.run
    end
  end

  let(:path) { File.join(@tmpdir, 'qtimetrap', 'config.yml') }
  let(:store) { described_class.new(path: path) }

  it 'returns nil when config is absent' do
    expect(store.read_theme_name).to be_nil
  end

  it 'writes and reads theme name' do
    store.write_theme_name('dark')

    expect(store.read_theme_name).to eq('dark')
    expect(File.read(path)).to include('theme: dark')
  end

  it 'returns nil for invalid yaml' do
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, ': bad : yaml')

    expect(store.read_theme_name).to be_nil
  end
end
