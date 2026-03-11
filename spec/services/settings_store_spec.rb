# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe QTimetrap::Services::SettingsStore do
  let(:tmpdir) { Dir.mktmpdir }
  let(:path) { File.join(tmpdir, 'qtimetrap', 'config.yml') }
  let(:store) { described_class.new(path: path) }

  after do
    FileUtils.rm_rf(tmpdir)
  end

  it 'returns nil when config is absent' do
    expect(store.read_theme_name).to be_nil
  end

  it 'writes and reads theme name' do
    store.write_theme_name('dark')
    expect_theme_persisted('dark')
  end

  it 'returns nil for invalid yaml' do
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, ': bad : yaml')

    expect(store.read_theme_name).to be_nil
  end

  it 'writes and reads window geometry' do
    store.write_window_geometry(left: 20, top: 30, width: 1400, height: 900)
    expect_window_geometry_persisted(left: 20, top: 30, width: 1400, height: 900)
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

  private

  def expect_theme_persisted(theme_name)
    expect(store.read_theme_name).to eq(theme_name)
    expect(File.read(path)).to include("theme: #{theme_name}")
  end

  def expect_window_geometry_persisted(left:, top:, width:, height:)
    expect(store.read_window_geometry).to eq(left: left, top: top, width: width, height: height)
    expect(File.read(path)).to include('window:')
  end
end
