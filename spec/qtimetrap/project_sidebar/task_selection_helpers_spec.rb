# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ProjectSidebar::TaskSelectionHelpers do
  subject(:host) { host_class.new }

  let(:host_class) do
    Class.new do
      include QTimetrap::ProjectSidebar::TaskSelectionHelpers

      attr_reader :selected_task_indices, :last_task_anchor_index, :task_values

      def initialize
        @task_values = []
        @selected_task_indices = []
        @last_task_anchor_index = nil
      end
    end
  end

  it 'sets selection and anchor when selected_task exists in refreshed values' do
    host.send(:refresh_task_state, %w[core ops qa], 'ops')
    expect_task_selection(indices: [1], anchor: 1)
  end

  it 'does not set selection when selected_task is missing in refreshed values' do
    host.send(:refresh_task_state, %w[core ops qa], 'missing')
    expect_task_selection(indices: [], anchor: nil)
  end

  it 'removes an already selected index on toggle' do
    host.instance_variable_set(:@selected_task_indices, [0, 2])

    host.send(:toggle_task_index, 2)

    expect(host.selected_task_indices).to eq([0])
  end

  private

  def expect_task_selection(indices:, anchor:)
    expect(host.selected_task_indices).to eq(indices)
    expect(host.last_task_anchor_index).to eq(anchor)
  end
end
