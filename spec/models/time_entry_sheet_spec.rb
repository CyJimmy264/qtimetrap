# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Models::TimeEntry do
  describe 'sheet parsing' do
    it 'splits project and task' do
      entry = described_class.new(id: 1, note: 'n', sheet: 'acme|billing', start_time: nil, end_time: nil)
      expect_sheet_parts(entry, 'acme', 'billing')
    end

    it 'handles empty sheet with defaults' do
      entry = described_class.new(id: 1, note: 'n', sheet: '   ', start_time: nil, end_time: nil)
      expect_sheet_parts(entry, '(default)', '(default task)')
    end
  end

  private

  def expect_sheet_parts(entry, project, task)
    expect(entry.project).to eq(project)
    expect(entry.task).to eq(task)
  end
end
