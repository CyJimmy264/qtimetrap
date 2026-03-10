# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::EntryNodesBuilder do
  it 'groups project entries, sorts by start time desc and fills empty note' do
    project = first_project_node(build_nodes(grouped_entries))

    expect(project[:label]).to eq('acme | core (2) 02:30:00')
    expect(project_entry_labels(project))
      .to eq(['10:00 - 11:00  01:00:00  (no note)', '08:00 - 09:30  01:30:00  fix bug'])
  end

  it 'sorts project nodes inside day by latest entry time desc' do
    project_labels = day_project_labels(build_nodes(project_sort_entries))

    expect(project_labels.first).to start_with('QTimetrap | task2')
    expect(project_labels.last).to start_with('cvetidnya.ru | task1')
  end

  private

  def build_nodes(entries)
    described_class.new(entries: entries, selected_project: '* ALL').build
  end

  def grouped_entries
    [
      build_entry(id: 1, note: '', sheet: 'acme|core',
                  start_at: '2026-02-28 10:00:00 +0000', end_at: '2026-02-28 11:00:00 +0000'),
      build_entry(id: 2, note: 'fix bug', sheet: 'acme|core',
                  start_at: '2026-02-28 08:00:00 +0000', end_at: '2026-02-28 09:30:00 +0000')
    ]
  end

  def project_sort_entries
    [
      build_entry(id: 1, note: 'older project', sheet: 'cvetidnya.ru|task1',
                  start_at: '2026-03-01 16:18:00 +0000', end_at: '2026-03-01 16:18:33 +0000'),
      build_entry(id: 2, note: 'newer project', sheet: 'QTimetrap|task2',
                  start_at: '2026-03-01 16:26:00 +0000', end_at: '2026-03-01 16:27:00 +0000')
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

  def first_project_node(nodes)
    nodes.first[:children].first[:children].first
  end

  def project_entry_labels(project)
    project[:children].map { |node| node[:label] }
  end

  def day_project_labels(nodes)
    nodes.first[:children].first[:children].map { |node| node[:label] }
  end
end
