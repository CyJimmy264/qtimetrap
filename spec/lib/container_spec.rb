# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Container do
  let(:config) { instance_double(QTimetrap::Configuration, theme_name: 'light', timetrap_bin: 't') }
  let(:deps) do
    {
      theme: instance_double(QTimetrap::Styles::Theme),
      gateway: instance_double(QTimetrap::Services::TimetrapGateway),
      archived_entries_store: instance_double(QTimetrap::Services::ArchivedEntriesStore),
      view_model: instance_double(QTimetrap::ViewModels::MainViewModel),
      main_window: instance_double(QTimetrap::Views::MainWindow),
      settings_store: instance_double(QTimetrap::Services::SettingsStore)
    }
  end

  before do
    allow(QTimetrap::Styles::Theme).to receive(:new).and_return(deps.fetch(:theme))
    allow(QTimetrap::Services::SettingsStore).to receive(:new).and_return(deps.fetch(:settings_store))
    allow(QTimetrap::Services::ArchivedEntriesStore).to receive(:new).and_return(deps.fetch(:archived_entries_store))
    allow(QTimetrap::Services::TimetrapGateway).to receive(:new).with(bin: 't').and_return(deps.fetch(:gateway))
    allow(QTimetrap::ViewModels::MainViewModel).to receive(:new).with(
      gateway: deps.fetch(:gateway),
      archived_entries_store: deps.fetch(:archived_entries_store)
    ).and_return(deps.fetch(:view_model))
    allow(QTimetrap::Views::MainWindow).to receive(:new).with(
      view_model: deps.fetch(:view_model),
      theme: deps.fetch(:theme),
      settings_store: deps.fetch(:settings_store)
    ).and_return(deps.fetch(:main_window))
  end

  it 'builds default graph and memoizes fetched dependencies' do
    container = described_class.new(config: config)

    expect(container.fetch(:theme)).to equal(deps.fetch(:theme))
    expect(container.fetch('theme')).to equal(deps.fetch(:theme))
    expect(QTimetrap::Styles::Theme).to have_received(:new).once

    expect(container.fetch(:main_window)).to equal(deps.fetch(:main_window))
    expect(container.fetch(:main_window)).to equal(deps.fetch(:main_window))
    expect(QTimetrap::Views::MainWindow).to have_received(:new).once
  end

  it 'supports runtime registration and symbolized keys' do
    container = described_class.new(config: config)
    calls = 0
    container.register('custom') do
      calls += 1
      :value
    end

    expect(container.fetch(:custom)).to eq(:value)
    expect(container.fetch('custom')).to eq(:value)
    expect(calls).to eq(1)
  end
end
