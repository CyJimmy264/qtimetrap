# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  it 'updates entry task through gateway and refreshes data' do
    view_model.refresh!

    view_model.update_entry_task(entry_today.id, 'deploy')

    expect(gateway).to have_received(:update_task).with(entry_today.id, 'acme|deploy')
    expect(gateway).to have_received(:entries).at_least(:twice)
  end

  it 'updates current task input when moving running entry' do
    running_entry = QTimetrap::Models::TimeEntry.new(
      id: 7,
      note: 'ship it',
      sheet: 'acme|core',
      start_time: Time.now - 120,
      end_time: nil
    )
    allow(gateway).to receive(:entries).and_return([running_entry])

    view_model.refresh!
    view_model.update_entry_task(running_entry.id, 'deploy')

    expect(view_model.current_task_input).to eq('deploy')
  end
end
