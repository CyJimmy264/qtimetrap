# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_qt_boot
  include_context :main_window_setup
  include_context :main_window_cleanup

  it 'toggles visibility through public show/close API' do
    expect(window_visibility_after_show_and_close).to eq([true, false])
  end

  it 'restores and persists window geometry through settings store' do
    restored_window, restored_qt_window = restore_and_persist_window_geometry
    expect(restored_qt_window).not_to be_nil
  ensure
    restored_window&.send(:heartbeat)&.stop
    restored_qt_window&.close
  end

  it 'sets pending refresh when refresh button is clicked' do
    main_window.instance_variable_set(:@pending_refresh, false)
    button_with_text('REFRESH').click
    expect(main_window.instance_variable_get(:@pending_refresh)).to be(true)
  end

  it 'logs and continues when start fails' do
    allow(view_model).to receive(:start_tracking).and_raise(StandardError, 'boom')
    allow(main_window).to receive(:warn)
    button_with_text('START').click
    expect(main_window).to have_received(:warn).with(include('[qtimetrap] start failed: StandardError: boom'))
  end

  it 'logs and continues when stop fails' do
    allow(view_model).to receive(:running_current_sheet?).and_return(true)
    allow(view_model).to receive(:stop_tracking).and_raise(StandardError, 'boom')
    trigger_window_warning('STOP')
    expect(main_window).to have_received(:warn).with(include('[qtimetrap] stop failed: StandardError: boom'))
  end

  it 'logs and continues when theme persistence fails' do
    allow(settings_store).to receive(:write_theme_name).and_raise(StandardError, 'boom')
    main_window.send(:render!)
    allow(main_window).to receive(:warn)
    theme_button.click
    expect(main_window).to have_received(:warn).with(include('[qtimetrap] save theme failed: StandardError: boom'))
  end

  it 'defers UI rerender after entry time update to heartbeat' do
    invoke_deferred_refresh(:handle_entry_time_changed, 1, '10:00', '11:00')
    expect_deferred_entry_update(:update_entry_time, 1, '10:00', '11:00')
  end

  it 'defers UI rerender after entry task update to heartbeat' do
    invoke_deferred_refresh(:handle_entry_task_changed, 1, 'deploy')
    expect_deferred_entry_update(:update_entry_task, 1, 'deploy')
  end

  it 'archives entry through view model and defers rerender to heartbeat' do
    invoke_deferred_refresh(:handle_entry_archived, 1)
    expect_deferred_entry_update(:archive_entry, 1)
  end

  it 'restores archived entry through view model and defers rerender to heartbeat' do
    allow(view_model).to receive(:archive_mode?).and_return(true)
    invoke_deferred_refresh(:handle_entry_archived, 1)
    expect_deferred_entry_update(:unarchive_entry, 1)
  end

  it 'ignores key press when event payload has no key data' do
    main_window.send(:on_key_press, {})
    expect(main_window.instance_variable_get(:@shutdown_requested)).to be(false)
  end

  it 'logs and continues when icon loader fails', :silence_stderr do
    break_window_icon_loader
    expect(main_window).to have_received(:warn).with(include('[qtimetrap] icon load failed: StandardError: icon boom'))
  end

  private

  def expect_window_geometry(window, values)
    expect([window.x, window.y, window.width, window.height]).to eq(values)
  end

  def expect_persisted_geometry
    expect(settings_store).to have_received(:write_window_geometry).with(
      left: 70,
      top: 80,
      width: 1200,
      height: 760
    )
  end

  def restore_and_persist_window_geometry
    restored_window, restored_qt_window = build_restored_window
    expect_window_geometry(restored_qt_window, [70, 80, 1200, 760])
    restored_window.close
    expect_persisted_geometry
    [restored_window, restored_qt_window]
  end

  def build_restored_window
    allow(settings_store).to receive(:read_window_geometry).and_return(left: 70, top: 80, width: 1200, height: 760)
    allow(settings_store).to receive(:write_window_geometry)
    restored_window = described_class.new(view_model: view_model, settings_store: settings_store)
    [restored_window, restored_window.send(:window)]
  end

  def window_visibility_after_show_and_close
    main_window.show
    QApplication.process_events
    visible_after_show = qt_window.is_visible
    main_window.close
    QApplication.process_events
    [visible_after_show, qt_window.is_visible]
  end

  def trigger_window_warning(button_text)
    main_window.send(:render!)
    allow(main_window).to receive(:warn)
    button_with_text(button_text).click
  end

  def invoke_deferred_refresh(method_name, *args)
    allow(main_window).to receive(:render!)
    main_window.instance_variable_set(:@pending_refresh, false)
    main_window.send(method_name, *args)
  end

  def expect_deferred_entry_update(message, *args)
    expect(view_model).to have_received(message).with(*args)
    expect(main_window.instance_variable_get(:@pending_refresh)).to be(true)
    expect(main_window).not_to have_received(:render!)
  end

  def break_window_icon_loader
    broken_loader = instance_double(QTimetrap::Views::WindowIconLoader)
    allow(QTimetrap::Views::WindowIconLoader).to receive(:new).and_return(broken_loader)
    allow(broken_loader).to receive(:apply).and_raise(StandardError, 'icon boom')
    allow(main_window).to receive(:warn)
    main_window.send(:set_window_icon)
  end
end
