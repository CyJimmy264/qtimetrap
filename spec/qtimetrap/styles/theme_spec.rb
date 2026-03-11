# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Styles::Theme do
  let(:root) { QTimetrap::Application.root }

  it 'loads light theme by default for unknown names' do
    theme = described_class.new(name: 'unknown', root: root)
    expect_theme_state(theme, name: 'light', stylesheet_fragment: 'QWidget#main_window')
  end

  it 'creates a new theme instance with another name' do
    light = described_class.new(name: 'light', root: root)
    dark = light.with_name('dark')
    expect(dark).not_to equal(light)
    expect_theme_state(dark, name: 'dark', stylesheet_fragment: '#0f172a')
  end

  private

  def expect_theme_state(theme, name:, stylesheet_fragment:)
    expect(theme.name).to eq(name)
    expect(theme.application_stylesheet).to include(stylesheet_fragment)
  end
end
