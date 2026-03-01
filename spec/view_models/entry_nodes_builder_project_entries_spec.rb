# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::EntryNodesBuilder do
  it 'groups project entries, sorts by start time desc and fills empty note' do
    entries = [
      QTimetrap::Models::TimeEntry.new(
        id: 1, note: '', sheet: 'acme|core',
        start_time: Time.parse('2026-02-28 10:00:00 +0000'),
        end_time: Time.parse('2026-02-28 11:00:00 +0000')
      ),
      QTimetrap::Models::TimeEntry.new(
        id: 2, note: 'fix bug', sheet: 'acme|core',
        start_time: Time.parse('2026-02-28 08:00:00 +0000'),
        end_time: Time.parse('2026-02-28 09:30:00 +0000')
      )
    ]

    nodes = described_class.new(entries: entries, selected_project: '* ALL').build
    project = nodes.first[:children].first[:children].first
    labels = project[:children].map { |node| node[:label] }

    expect(project[:label]).to eq('acme | core (2) 02:30:00')
    expect(labels).to eq(['10:00 - 11:00  01:00:00  (no note)', '08:00 - 09:30  01:30:00  fix bug'])
  end

  it 'sorts project nodes inside day by latest entry time desc' do
    entries = [
      QTimetrap::Models::TimeEntry.new(
        id: 1, note: 'older project', sheet: 'cvetidnya.ru|task1',
        start_time: Time.parse('2026-03-01 16:18:00 +0000'),
        end_time: Time.parse('2026-03-01 16:18:33 +0000')
      ),
      QTimetrap::Models::TimeEntry.new(
        id: 2, note: 'newer project', sheet: 'QTimetrap|task2',
        start_time: Time.parse('2026-03-01 16:26:00 +0000'),
        end_time: Time.parse('2026-03-01 16:27:00 +0000')
      )
    ]

    nodes = described_class.new(entries: entries, selected_project: '* ALL').build
    project_labels = nodes.first[:children].first[:children].map { |node| node[:label] }

    expect(project_labels.first).to start_with('QTimetrap | task2')
    expect(project_labels.last).to start_with('cvetidnya.ru | task1')
  end
end
