# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  let(:entry_in_range) do
    QTimetrap::Models::TimeEntry.new(
      id: 11,
      note: 'in range',
      sheet: 'acme|core',
      start_time: Time.new(2026, 3, 1, 11, 0, 0, '+00:00'),
      end_time: Time.new(2026, 3, 1, 11, 30, 0, '+00:00')
    )
  end
  let(:entry_out_of_range) do
    QTimetrap::Models::TimeEntry.new(
      id: 12,
      note: 'out of range',
      sheet: 'acme|core',
      start_time: Time.new(2026, 3, 2, 11, 0, 0, '+00:00'),
      end_time: Time.new(2026, 3, 2, 11, 30, 0, '+00:00')
    )
  end

  before do
    allow(gateway).to receive(:entries).and_return([entry_in_range, entry_out_of_range])
    view_model.refresh!
  end

  it 'filters nodes by date-time interval' do
    view_model.update_time_range_filter(
      from_at: Time.new(2026, 3, 1, 0, 0, 0, '+00:00'),
      to_at: Time.new(2026, 3, 1, 23, 59, 0, '+00:00')
    )

    labels = view_model.entry_nodes
                       .flat_map { |week| week.fetch(:children) }
                       .flat_map { |day| day.fetch(:children) }
                       .map { |project| project.fetch(:label) }
                       .join(' ')

    expect(labels).to include('acme | core')
    expect(view_model.total_seconds).to eq(entry_in_range.duration_seconds)
  end

  it 'accepts date-only upper bound as end of day' do
    view_model.update_time_range_filter(from_at: nil, to_at: Time.new(2026, 3, 1, 23, 59, 59, '+00:00'))

    expect(view_model.total_seconds).to eq(entry_in_range.duration_seconds)
  end

  it 'raises when FROM is after TO' do
    expect do
      view_model.update_time_range_filter(
        from_at: Time.new(2026, 3, 2, 10, 0, 0, '+00:00'),
        to_at: Time.new(2026, 3, 1, 10, 0, 0, '+00:00')
      )
    end.to raise_error(ArgumentError, /FROM must be less than or equal to TO/)
  end
end
