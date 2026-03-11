# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::EntryNodesBuilder do
  it 'builds week and day nodes with totals' do
    nodes = described_class.new(entries: entries, selected_project: '* ALL').build
    expect_totals_nodes(nodes)
  end

  private

  def entries
    [
      build_entry(id: 1, note: 'a', sheet: 'acme|core',
                  start_at: '2026-02-28 10:00:00 +0000', end_at: '2026-02-28 11:00:00 +0000'),
      build_entry(id: 2, note: 'b', sheet: 'beta|ops',
                  start_at: '2026-02-27 12:00:00 +0000', end_at: '2026-02-27 13:00:00 +0000')
    ]
  end

  def build_entry(id:, note:, sheet:, start_at:, end_at:)
    QTimetrap::Models::TimeEntry.new(
      id: id,
      note: note,
      sheet: sheet,
      start_time: Time.parse(start_at),
      end_time: Time.parse(end_at)
    )
  end

  def expect_totals_nodes(nodes)
    expect(nodes.size).to eq(1)
    expect(nodes.first[:label]).to eq('Week Feb 23 - Mar 1  Total: 02:00:00')
    expect(nodes.first[:children].first[:label]).to eq('Sat, Feb 28  Total: 01:00:00')
  end
end
