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

  it 'writes and reads window geometry' do
    store.write_window_geometry(left: 20, top: 30, width: 1400, height: 900)

    expect(store.read_window_geometry).to eq(left: 20, top: 30, width: 1400, height: 900)
    expect(File.read(path)).to include('window:')
  end

  it 'returns nil for invalid window geometry values' do
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, { 'window' => { 'left' => 10, 'top' => 20, 'width' => 0, 'height' => 200 } }.to_yaml)

    expect(store.read_window_geometry).to be_nil
  end

  it 'returns nil for type errors in window geometry values' do
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, { 'window' => { 'left' => 10, 'top' => 20, 'width' => [], 'height' => 200 } }.to_yaml)

    expect(store.read_window_geometry).to be_nil
  end

  it 'returns nil for missing required geometry keys' do
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, { 'window' => {} }.to_yaml)

    expect(store.read_window_geometry).to be_nil
  end
end
