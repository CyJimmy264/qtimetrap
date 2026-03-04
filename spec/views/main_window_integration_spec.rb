# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_qt_boot
  include_context :main_window_setup
  include_context :main_window_cleanup

  it 'toggles visibility through public show/close API' do
    main_window.show
    QApplication.process_events
    expect(qt_window.is_visible).to be(true)

    main_window.close
    QApplication.process_events
    expect(qt_window.is_visible).to be(false)
  end

  it 'restores and persists window geometry through settings store' do
    allow(settings_store).to receive(:read_window_geometry).and_return(left: 70, top: 80, width: 1200, height: 760)
    allow(settings_store).to receive(:write_window_geometry)

    window = described_class.new(view_model: view_model, settings_store: settings_store)
    qt_window = window.send(:window)
    expect([qt_window.x, qt_window.y, qt_window.width, qt_window.height]).to eq([70, 80, 1200, 760])

    window.close
    expect(settings_store).to have_received(:write_window_geometry).with(
      left: 70,
      top: 80,
      width: 1200,
      height: 760
    )
  ensure
    window&.send(:heartbeat)&.stop
    qt_window&.close
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
    main_window.send(:render!)
    allow(main_window).to receive(:warn)
    button_with_text('STOP').click
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
    allow(main_window).to receive(:render!)
    main_window.instance_variable_set(:@pending_refresh, false)

    main_window.send(:handle_entry_time_changed, 1, '10:00', '11:00')

    expect(view_model).to have_received(:update_entry_time).with(1, '10:00', '11:00')
    expect(main_window.instance_variable_get(:@pending_refresh)).to be(true)
    expect(main_window).not_to have_received(:render!)
  end

  it 'archives entry through view model and defers rerender to heartbeat' do
    allow(main_window).to receive(:render!)
    main_window.instance_variable_set(:@pending_refresh, false)

    main_window.send(:handle_entry_archived, 1)

    expect(view_model).to have_received(:archive_entry).with(1)
    expect(main_window.instance_variable_get(:@pending_refresh)).to be(true)
    expect(main_window).not_to have_received(:render!)
  end

  it 'ignores key press when event payload has no key data' do
    main_window.send(:on_key_press, {})
    expect(main_window.instance_variable_get(:@shutdown_requested)).to be(false)
  end

  it 'logs and continues when icon loader fails', :silence_stderr do
    broken_loader = instance_double(QTimetrap::Views::WindowIconLoader)
    allow(QTimetrap::Views::WindowIconLoader).to receive(:new).and_return(broken_loader)
    allow(broken_loader).to receive(:apply).and_raise(StandardError, 'icon boom')
    allow(main_window).to receive(:warn)
    main_window.send(:set_window_icon)
    expect(main_window).to have_received(:warn).with(include('[qtimetrap] icon load failed: StandardError: icon boom'))
  end
end
