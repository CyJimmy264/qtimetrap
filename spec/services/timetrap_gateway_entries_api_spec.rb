# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new }

  it 'maps timetrap entries to model objects via API' do
    stub_const('Timetrap', Module.new)
    Timetrap.const_set(:Timer, Class.new)
    Timetrap.const_set(:Entry, Class.new)
    first = build_api_entry_double(id: 1, note: 'note 1', sheet: 'acme|core',
                                   start_at: Time.new(2026, 2, 28, 10, 0, 0, '+00:00'),
                                   end_at: Time.new(2026, 2, 28, 11, 0, 0, '+00:00'))
    second = build_api_entry_double(id: 2, note: 'note 2', sheet: 'internal|ops',
                                    start_at: Time.new(2026, 2, 28, 12, 0, 0, '+00:00'),
                                    end_at: nil)
    relation = instance_double(api_relation_class, all: [first, second])
    allow(Timetrap::Entry).to receive(:order).with(:start).and_return(relation)

    entries = gateway.entries

    expect(entries.size).to eq(2)
    expect(entries.first.project).to eq('acme')
    expect(entries.last.task).to eq('ops')
  end

  private

  def build_api_entry_double(id:, note:, sheet:, start_at:, end_at:)
    entry = instance_double(api_entry_class, id: id, note: note, sheet: sheet)
    allow(entry).to receive(:[]).with(:start).and_return(start_at)
    allow(entry).to receive(:[]).with(:end).and_return(end_at)
    entry
  end

  def api_entry_class
    Class.new do
      def id; end
      def note; end
      def sheet; end
      def [](key); end
    end
  end

  def api_relation_class
    Class.new do
      def all; end
    end
  end
end
