# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_setup
  include_context :main_window_cleanup

  it 'renders summary, project and entries from view model' do
    main_window.send(:render!)
    expect(qt_window).to have_child_with_text('Week total: 00:10:00 | Total: 02:00:00')
    expect(qt_window).to have_child_with_text('Project: acme')
    expect(qt_window).to have_child_with_text('Fri, Feb 28  Total: 01:00:00')
    expect(qt_window).to have_child_with_text('  acme | core (1) 01:00:00')
  end

  it 'switches theme at runtime from toolbar button' do
    main_window.send(:render!)
    expect(theme_button.text.to_s).to eq('THEME: LIGHT')
    theme_button.click
    expect(theme_button.text.to_s).to eq('THEME: DARK')
    expect(qt_window.style_sheet.to_s).to include('#0f172a')
    expect(settings_store).to have_received(:write_theme_name).with('dark')
  end

  it 'updates selected project on sidebar project click' do
    main_window.send(:render!)
    button_with_text('acme').click
    expect(view_model).to have_received(:select_project).with('acme')
  end
end
