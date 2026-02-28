# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  it 'sends default note when blank' do
    view_model.start_tracking('  ')
    expect(gateway).to have_received(:start).with('gui-clockify')
    expect(view_model.current_started_at).not_to be_nil
  end

  it 'stops timer and clears running mark' do
    view_model.start_tracking('test')
    view_model.stop_tracking
    expect(gateway).to have_received(:stop)
    expect(view_model.current_started_at).to be_nil
  end
end
