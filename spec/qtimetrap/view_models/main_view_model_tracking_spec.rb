# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  it 'raises when start sheet is blank' do
    expect_blank_sheet_start_to_fail
  end

  it 'keeps utf-8 sheet content when starting' do
    sheet = 'Поднять задачу'

    view_model.start_tracking(sheet)

    expect(gateway).to have_received(:start).with('Поднять задачу')
  end

  it 'stops timer and clears running mark' do
    view_model.start_tracking('test')
    view_model.stop_tracking
    expect_stop_tracking_state
  end

  private

  def expect_blank_sheet_start_to_fail
    expect { view_model.start_tracking('  ') }.to raise_error(ArgumentError, 'Task is required')
    expect(gateway).not_to have_received(:start)
  end

  def expect_stop_tracking_state
    expect(gateway).to have_received(:stop)
    expect(view_model.current_started_at).to be_nil
  end
end
