# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindowSplitterToggleHoverHelpers do
  subject(:host) { host_class.new }

  include_context :qt

  let(:host_class) do
    Class.new do
      include QTimetrap::Views::MainWindowSplitterToggleHoverHelpers
    end
  end

  let(:parent) { QWidget.new }
  let(:button) { QPushButton.new(parent) }

  after do
    parent.close if parent.respond_to?(:close)
    QApplication.process_events
  end

  it 'shows and raises button on zone enter and cancels pending hide timer' do
    state = { zone_hovered: false, button_hovered: false }

    host.send(:schedule_toggle_hide, button: button, state: state)
    timer = state.fetch(:hide_timer)
    expect(timer.is_active).to be(true)

    host.send(:on_toggle_zone_enter, button: button, state: state)

    expect(state[:zone_hovered]).to be(true)
    expect(timer.is_active).to be(false)
  end

  it 'hides button after leave timeout when no hover remains' do
    state = { zone_hovered: true, button_hovered: false }
    button.show

    host.send(:on_toggle_zone_leave, button: button, state: state)
    timer = state.fetch(:hide_timer)
    expect(timer.is_active).to be(true)

    sleep 0.06
    QApplication.process_events

    expect(state[:zone_hovered]).to be(false)
    expect(button.is_visible).to be(false)
    expect(timer.is_active).to be(false)
  end

  it 'keeps button visible when pointer enters button and hides after leave' do
    state = { zone_hovered: false, button_hovered: false }
    button.show

    host.send(:on_toggle_button_enter, button: button, state: state)
    expect(state[:button_hovered]).to be(true)

    host.send(:on_toggle_button_leave, button: button, state: state)
    timer = state.fetch(:hide_timer)
    expect(state[:button_hovered]).to be(false)
    expect(timer.is_active).to be(true)

    sleep 0.06
    QApplication.process_events

    expect(button.is_visible).to be(false)
  end

  it 'reuses same hide timer across repeated schedules' do
    state = {}

    host.send(:schedule_toggle_hide, button: button, state: state)
    first_timer = state.fetch(:hide_timer)
    host.send(:schedule_toggle_hide, button: button, state: state)
    second_timer = state.fetch(:hide_timer)

    expect(second_timer).to equal(first_timer)
  end
end
