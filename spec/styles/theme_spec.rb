# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Styles::Theme do
  let(:root) { QTimetrap::Application.root }

  it 'loads light theme by default for unknown names' do
    theme = described_class.new(name: 'unknown', root: root)

    expect(theme.name).to eq('light')
    expect(theme.application_stylesheet).to include('QWidget#main_window')
  end

  it 'creates a new theme instance with another name' do
    light = described_class.new(name: 'light', root: root)
    dark = light.with_name('dark')

    expect(dark).not_to equal(light)
    expect(dark.name).to eq('dark')
    expect(dark.application_stylesheet).to include('#0f172a')
  end
end
