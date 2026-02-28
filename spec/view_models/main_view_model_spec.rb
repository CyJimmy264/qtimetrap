# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  Entry = QTimetrap::Models::TimeEntry

  let(:gateway) { instance_double(QTimetrap::Services::TimetrapGateway) }
  let(:view_model) { described_class.new(gateway: gateway) }

  let(:entry_today) do
    Entry.new(
      id: 1,
      note: 'build widget',
      sheet: 'acme|core',
      start_time: Time.now - 3600,
      end_time: Time.now
    )
  end

  let(:entry_other_project) do
    Entry.new(
      id: 2,
      note: 'bugfix',
      sheet: 'internal|ops',
      start_time: Time.now - 1800,
      end_time: Time.now
    )
  end

  before do
    allow(gateway).to receive(:active_started_at).and_return(nil)
    allow(gateway).to receive(:entries).and_return([entry_today, entry_other_project])
    allow(gateway).to receive(:start)
    allow(gateway).to receive(:stop)
  end

  describe '#refresh!' do
    it 'loads entries and keeps ALL selected by default' do
      view_model.refresh!

      expect(view_model.entries.size).to eq(2)
      expect(view_model.selected_project).to eq('* ALL')
    end
  end

  describe '#project_names' do
    it 'returns sorted project names with ALL first' do
      view_model.refresh!

      expect(view_model.project_names).to eq(['* ALL', 'acme', 'internal'])
    end
  end

  describe '#filtered_entries' do
    it 'filters by selected project' do
      view_model.refresh!
      view_model.select_project('acme')

      expect(view_model.filtered_entries.map(&:project)).to eq(['acme'])
    end
  end

  describe '#start_tracking' do
    it 'sends default note when blank' do
      view_model.start_tracking('  ')

      expect(gateway).to have_received(:start).with('gui-clockify')
      expect(view_model.current_started_at).not_to be_nil
    end
  end

  describe '#stop_tracking' do
    it 'stops timer and clears running mark' do
      view_model.start_tracking('test')
      view_model.stop_tracking

      expect(gateway).to have_received(:stop)
      expect(view_model.current_started_at).to be_nil
    end
  end
end
