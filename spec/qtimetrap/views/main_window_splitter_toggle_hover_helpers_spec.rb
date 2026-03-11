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
    timer = schedule_toggle_hide(state)
    expect_zone_enter_to_cancel_hide(state, timer)
  end

  it 'hides button after leave timeout when no hover remains' do
    state = { zone_hovered: true, button_hovered: false }
    leave_zone_and_wait(state)
    expect_zone_leave_to_hide_button(state)
  end

  it 'keeps button visible when pointer enters button and hides after leave' do
    state = { zone_hovered: false, button_hovered: false }
    leave_button_and_wait(state)
    expect_button_leave_to_hide(state)
  end

  it 'reuses same hide timer across repeated schedules' do
    state = {}
    first_timer = schedule_toggle_hide(state)
    second_timer = schedule_toggle_hide(state)
    expect(second_timer).to equal(first_timer)
  end

  private

  def schedule_toggle_hide(state)
    host.send(:schedule_toggle_hide, button: button, state: state)
    state.fetch(:hide_timer)
  end

  def expect_zone_enter_to_cancel_hide(state, timer)
    expect(timer.is_active).to be(true)
    host.send(:on_toggle_zone_enter, button: button, state: state)
    expect(state[:zone_hovered]).to be(true)
    expect(timer.is_active).to be(false)
  end

  def leave_zone_and_wait(state)
    button.show
    host.send(:on_toggle_zone_leave, button: button, state: state)
    wait_for_hide_timer
  end

  def expect_zone_leave_to_hide_button(state)
    expect(state[:zone_hovered]).to be(false)
    expect(button.is_visible).to be(false)
    expect(state.fetch(:hide_timer).is_active).to be(false)
  end

  def leave_button_and_wait(state)
    button.show
    host.send(:on_toggle_button_enter, button: button, state: state)
    expect(state[:button_hovered]).to be(true)
    host.send(:on_toggle_button_leave, button: button, state: state)
    wait_for_hide_timer
  end

  def expect_button_leave_to_hide(state)
    expect(state[:button_hovered]).to be(false)
    expect(state.fetch(:hide_timer).is_active).to be(false)
    expect(button.is_visible).to be(false)
  end

  def wait_for_hide_timer
    sleep 0.06
    QApplication.process_events
  end
end
