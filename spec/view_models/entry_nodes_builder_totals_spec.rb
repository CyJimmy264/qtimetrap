# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::EntryNodesBuilder do
  it 'builds week and day nodes with totals' do
    entries = [
      QTimetrap::Models::TimeEntry.new(
        id: 1, note: 'a', sheet: 'acme|core',
        start_time: Time.parse('2026-02-28 10:00:00 +0000'),
        end_time: Time.parse('2026-02-28 11:00:00 +0000')
      ),
      QTimetrap::Models::TimeEntry.new(
        id: 2, note: 'b', sheet: 'beta|ops',
        start_time: Time.parse('2026-02-27 12:00:00 +0000'),
        end_time: Time.parse('2026-02-27 13:00:00 +0000')
      )
    ]

    nodes = described_class.new(entries: entries, selected_project: '* ALL').build

    expect(nodes.size).to eq(1)
    expect(nodes.first[:label]).to eq('Week Feb 23 - Mar 1  Total: 02:00:00')
    expect(nodes.first[:children].first[:label]).to eq('Sat, Feb 28  Total: 01:00:00')
  end
end
