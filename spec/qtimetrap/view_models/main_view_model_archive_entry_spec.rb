# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  let(:archived_entries_store) { instance_double(QTimetrap::Services::ArchivedEntriesStore) }
  let(:view_model) do
    described_class.new(
      gateway: gateway,
      archived_entries_store: archived_entries_store
    )
  end

  before do
    allow(archived_entries_store).to receive(:archived?).and_return(false)
    allow(archived_entries_store).to receive(:archive)
  end

  it 'archives entry id through archived store' do
    view_model.archive_entry(1)

    expect(archived_entries_store).to have_received(:archive).with(1)
  end

  it 'unarchives entry id through archived store' do
    view_model.unarchive_entry(1)

    expect(archived_entries_store).to have_received(:unarchive).with(1)
  end

  it 'hides archived entries from filtered collection' do
    allow(archived_entries_store).to receive(:archived?) { |id| id == 1 }
    view_model.refresh!
    expect(rendered_entry_ids).not_to include(1)
  end

  it 'shows only archived entries when archive-only mode is enabled' do
    allow(archived_entries_store).to receive(:archived?) { |id| id == 1 }
    view_model.refresh!
    view_model.archive_mode = true
    expect_archive_mode_render_state
  end

  it 'shows archived tasks for selected project in archive-only mode' do
    allow(archived_entries_store).to receive(:archived?) { |id| id == 1 }
    view_model.refresh!
    view_model.archive_mode = true
    view_model.select_project('acme')

    expect(view_model.task_names_for_selected_project).to eq(['core'])
  end

  private

  def rendered_entry_ids
    view_model.entry_nodes
              .flat_map { |week| week.fetch(:children) }
              .flat_map { |day| day.fetch(:children) }
              .flat_map { |project| project.fetch(:children) }
              .map { |entry| entry.fetch(:entry_id) }
  end

  def expect_archive_mode_render_state
    expect(rendered_entry_ids).to eq([1])
    expect(view_model.project_names).to eq(['* ALL', 'acme'])
    expect(view_model.task_names_for_selected_project).to eq([])
  end
end
