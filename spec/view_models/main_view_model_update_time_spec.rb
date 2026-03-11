# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  it 'updates entry time through gateway and refreshes data' do
    view_model.refresh!
    view_model.update_entry_time(entry_today.id, '10:15', '11:30')
    expect_time_update('10:15', '11:30')
  end

  it 'raises for invalid clock value' do
    view_model.refresh!

    expect { view_model.update_entry_time(entry_today.id, 'aa:bb', '11:30') }
      .to raise_error(ArgumentError, /Invalid time value/)
  end

  private

  def expect_time_update(start_label, end_label)
    start_time, end_time = expected_time_range(start_label, end_label)
    expect(gateway).to have_received(:update_time).with(entry_today.id, start_time: start_time, end_time: end_time)
    expect(gateway).to have_received(:entries).at_least(:twice)
  end

  def expected_time_range(start_label, end_label)
    start_base = entry_today.start_time
    end_base = entry_today.end_time || entry_today.start_time
    [
      build_time(start_base, start_label),
      build_time(end_base, end_label)
    ]
  end

  def build_time(base_time, clock_value)
    hours, minutes = clock_value.split(':').map(&:to_i)
    Time.new(base_time.year, base_time.month, base_time.day, hours, minutes, 0, base_time.utc_offset)
  end
end
