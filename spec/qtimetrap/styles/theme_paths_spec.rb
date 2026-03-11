# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require 'fileutils'

RSpec.describe QTimetrap::Styles::Theme do
  let(:tmp_root) { Dir.mktmpdir('qtimetrap-theme-spec') }

  after do
    FileUtils.remove_entry(tmp_root)
  end

  it 'falls back to default stylesheet when a themed file is missing' do
    write_qss('light', 'application', 'QWidget { color: #111; }')

    theme = described_class.new(name: 'dark', root: tmp_root)
    expect(theme.stylesheet('application')).to include('color: #111')
  end

  it 'reads snippet from active theme and falls back to default snippet' do
    write_snippet('dark', 'badge', 'QLabel#badge { color: #fff; }')
    write_snippet('light', 'chip', 'QLabel#chip { color: #111; }')

    dark = described_class.new(name: 'dark', root: tmp_root)
    expect_snippets(dark, badge: '#badge', chip: '#chip')
  end

  private

  def write_qss(theme, file_name, content)
    path = File.join(tmp_root, 'app', 'styles', 'themes', theme, "#{file_name}.qss")
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def write_snippet(theme, name, content)
    path = File.join(tmp_root, 'app', 'styles', 'themes', theme, 'snippets', "#{name}.qss")
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def expect_snippets(theme, badge:, chip:)
    expect(theme.snippet('badge')).to include(badge)
    expect(theme.snippet('chip')).to include(chip)
  end
end
