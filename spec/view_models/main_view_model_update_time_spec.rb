# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  it 'updates entry time through gateway and refreshes data' do
    view_model.refresh!
    base = entry_today.start_time
    start_time = Time.new(base.year, base.month, base.day, 10, 15, 0, base.utc_offset)
    end_time = Time.new(base.year, base.month, base.day, 11, 30, 0, base.utc_offset)

    view_model.update_entry_time(entry_today.id, '10:15', '11:30')

    expect(gateway).to have_received(:update_time).with(entry_today.id, start_time: start_time, end_time: end_time)
    expect(gateway).to have_received(:entries).at_least(:twice)
  end

  it 'raises for invalid clock value' do
    view_model.refresh!

    expect { view_model.update_entry_time(entry_today.id, 'aa:bb', '11:30') }
      .to raise_error(ArgumentError, /Invalid time value/)
  end
end
