# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new }

  it 'maps timetrap entries to model objects via API' do
    stub_const('Timetrap', Module.new)
    Timetrap.const_set(:Timer, Class.new)
    Timetrap.const_set(:Entry, Class.new)
    first = instance_double('TimetrapEntry', id: 1, note: 'note 1', sheet: 'acme|core')
    second = instance_double('TimetrapEntry', id: 2, note: 'note 2', sheet: 'internal|ops')
    allow(first).to receive(:[]).with(:start).and_return(Time.new(2026, 2, 28, 10, 0, 0, '+00:00'))
    allow(first).to receive(:[]).with(:end).and_return(Time.new(2026, 2, 28, 11, 0, 0, '+00:00'))
    allow(second).to receive(:[]).with(:start).and_return(Time.new(2026, 2, 28, 12, 0, 0, '+00:00'))
    allow(second).to receive(:[]).with(:end).and_return(nil)
    relation = instance_double('EntryRelation', all: [first, second])
    allow(Timetrap::Entry).to receive(:order).with(:start).and_return(relation)
    entries = gateway.entries
    expect(entries.size).to eq(2)
    expect(entries.first.project).to eq('acme')
    expect(entries.last.task).to eq('ops')
  end
end
