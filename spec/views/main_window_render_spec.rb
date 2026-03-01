# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_qt_boot
  include_context :main_window_setup
  include_context :main_window_cleanup

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

  it 'renders task shortcuts for selected non-all project and fills input on click' do
    allow(view_model).to receive_messages(
      selected_project: 'acme',
      task_names_for_selected_project: %w[core ops]
    )

    main_window.send(:render!)
    button_with_text('core').click

    input = widgets_of_type(qt_window, QLineEdit).first
    expect(input.text.to_s).to eq('acme|core')
  end

  it 'does not render task shortcuts when selected project is * ALL' do
    allow(view_model).to receive_messages(
      selected_project: '* ALL',
      task_names_for_selected_project: []
    )

    main_window.send(:render!)

    task_buttons = widgets_of_type(qt_window, QPushButton).select { |button| button.object_name == 'task_button' }
    expect(task_buttons).to be_empty
  end

  it 'uses single-select for task buttons by default' do
    allow(view_model).to receive_messages(
      selected_project: 'acme',
      task_names_for_selected_project: %w[core ops qa]
    )
    allow(QApplication).to receive(:keyboard_modifiers).and_return(0)

    main_window.send(:render!)
    core = button_with_text('core')
    ops = button_with_text('ops')

    core.click
    ops.click

    expect(core.is_checked).to be(false)
    expect(ops.is_checked).to be(true)
  end

  it 'allows multi-select with Ctrl for task buttons' do
    allow(view_model).to receive_messages(
      selected_project: 'acme',
      task_names_for_selected_project: %w[core ops qa]
    )

    main_window.send(:render!)
    core = button_with_text('core')
    ops = button_with_text('ops')

    allow(QApplication).to receive(:keyboard_modifiers).and_return(0)
    core.click
    allow(QApplication).to receive(:keyboard_modifiers).and_return(Qt::ControlModifier)
    ops.click

    expect(core.is_checked).to be(true)
    expect(ops.is_checked).to be(true)
  end

  it 'selects task range with Shift from last anchor' do
    allow(view_model).to receive_messages(
      selected_project: 'acme',
      task_names_for_selected_project: %w[core ops qa ux]
    )

    main_window.send(:render!)
    core = button_with_text('core')
    ops = button_with_text('ops')
    qa = button_with_text('qa')
    ux = button_with_text('ux')

    allow(QApplication).to receive(:keyboard_modifiers).and_return(0)
    core.click
    allow(QApplication).to receive(:keyboard_modifiers).and_return(Qt::ShiftModifier)
    qa.click

    expect(core.is_checked).to be(true)
    expect(ops.is_checked).to be(true)
    expect(qa.is_checked).to be(true)
    expect(ux.is_checked).to be(false)
  end
end
