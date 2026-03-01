# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  let(:entry_acme_ops) do
    QTimetrap::Models::TimeEntry.new(
      id: 3,
      note: 'ops task',
      sheet: 'acme|ops',
      start_time: Time.now - 900,
      end_time: Time.now
    )
  end

  before do
    allow(gateway).to receive(:entries).and_return([entry_today, entry_acme_ops, entry_other_project])
  end

  it 'filters entry nodes by selected tasks' do
    view_model.refresh!
    view_model.select_project('acme')
    view_model.select_tasks(['ops'])

    nodes = view_model.entry_nodes
    labels = nodes.flat_map { |week| week.fetch(:children) }
                  .flat_map { |day| day.fetch(:children) }
                  .map { |project| project.fetch(:label) }
                  .join(' ')

    expect(labels).to include('acme | ops')
    expect(labels).not_to include('acme | core')
  end
end
