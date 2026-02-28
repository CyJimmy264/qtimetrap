# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Models::TimeEntry do
  describe '#duration_seconds' do
    it 'returns elapsed seconds for finished entry' do
      entry = described_class.new(id: 1, note: 'work', sheet: 'proj|task',
                                  start_time: Time.new(2026, 2, 27, 10, 0, 0, '+00:00'),
                                  end_time: Time.new(2026, 2, 27, 11, 30, 0, '+00:00'))
      expect(entry.duration_seconds).to eq(5400)
    end

    it 'uses now for running entries' do
      entry = described_class.new(id: 1, note: 'work', sheet: 'proj|task',
                                  start_time: Time.new(2026, 2, 27, 10, 0, 0, '+00:00'), end_time: nil)
      now = Time.new(2026, 2, 27, 10, 1, 5, '+00:00')
      expect(entry.duration_seconds(now: now)).to eq(65)
    end
  end
end
