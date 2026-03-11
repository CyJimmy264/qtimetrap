# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Entries::ListComponent do
  include_context :qt

  let(:parent) { QWidget.new }
  let(:callbacks) do
    {
      on_entry_note_change: instance_double(Proc, call: nil),
      on_entry_task_change: instance_double(Proc, call: nil),
      task_suggestions_for_project: instance_double(Proc, call: %w[ops deploy core]),
      on_entry_time_change: instance_double(Proc, call: nil),
      on_entry_archive: instance_double(Proc, call: nil),
      on_time_range_change: instance_double(Proc, call: nil)
    }
  end
  let(:component) do
    described_class.new(
      parent: parent,
      callbacks: {
        on_entry_note_change: callbacks.fetch(:on_entry_note_change),
        on_entry_task_change: callbacks.fetch(:on_entry_task_change),
        on_entry_time_change: callbacks.fetch(:on_entry_time_change),
        on_entry_archive: callbacks.fetch(:on_entry_archive),
        on_time_range_change: callbacks.fetch(:on_time_range_change)
      },
      task_suggestions_for_project: callbacks.fetch(:task_suggestions_for_project)
    )
  end

  after do
    component.shutdown
    parent.close if parent.respond_to?(:close)
    QApplication.process_events
  end

  it 'applies expand/collapse all recursively and renders unknown leaf type as empty node style' do
    render_component(entry_nodes)
    collapse_all_nodes
    expect_expanded_state_and_unknown_leaf
  end

  it 'keeps branch nodes inside scroll viewport width for long labels' do
    parent.resize(920, 720)
    render_component(long_label_nodes, show_parent: true)
    expect_branch_widths_within_viewport
  end

  it 'activates note input on click and commits only on Enter' do
    render_component(entry_nodes)

    note_input = entry_note_input
    commit_note_input(note_input, 'updated note')
    expect(callbacks.fetch(:on_entry_note_change)).to have_received(:call).with(1, 'updated note')
  end

  it 'renders start/end inputs for entry rows' do
    render_component(entry_nodes)

    start_input = entry_start_input
    end_input = entry_end_input
    expect_time_inputs(start_input, end_input, start_text: '10:00', end_text: '11:00', read_only: true)
  end

  it 'renders editable task combo with recent task suggestions' do
    render_component(entry_nodes)

    task_input = entry_task_input
    expect_task_input_state(task_input)
  end

  it 'commits edited task value on Enter' do
    render_component(entry_nodes)
    commit_entry_task_input('deploy')
    expect_task_commit('deploy')
  end

  it 'commits selected task from combo activation' do
    render_component(entry_nodes)

    task_input = entry_task_input
    task_input.set_current_text('ops')
    component.send(:handle_entry_task_commit, task_input, 1, force: true)

    expect(callbacks.fetch(:on_entry_task_change)).to have_received(:call).with(1, 'ops')
  end

  it 'commits edited start/end values on Enter' do
    render_component(entry_nodes)

    start_input = entry_start_input
    end_input = entry_end_input
    commit_time_input_change(start_input, end_input)
    expect(callbacks.fetch(:on_entry_time_change)).to have_received(:call).with(1, '10:15', '11:00')
  end

  it 'does not commit time when input is already read-only' do
    render_component(entry_nodes)
    assert_time_input_ignores_commit_while_read_only
  end

  it 'deactivates note input on focus loss without committing' do
    render_component(entry_nodes)
    deactivate_note_input_without_commit
    expect_note_not_committed
  end

  it 'uses native placeholder for empty note and keeps text empty on activation' do
    render_component(no_note_entry_nodes)
    expect_empty_note_placeholder_on_activation
  end

  it 'keeps native placeholder on deactivation when input is blank' do
    render_component(no_note_entry_nodes)
    expect_empty_note_placeholder_on_deactivation
  end

  it 'extracts enter key code from hash payload with string key' do
    expect_hash_event_to_match_enter_key
  end

  it 'extracts key code from event object responding to key' do
    expect_object_event_to_match_enter_key
  end

  it 'renders toolbar date-time range controls and auto-applies filter callback' do
    render_component(entry_nodes)
    apply_time_filter_widget_values
    expect(callbacks.fetch(:on_time_range_change))
      .to have_received(:call).with(kind_of(Time), kind_of(Time)).at_least(:once)
  end

  it 'sends nil range when both date-time checkboxes are off' do
    render_component(entry_nodes)
    expect_nil_time_range_change
  end

  it 'keeps chosen from datetime when checkbox is off' do
    render_component(entry_nodes)
    chosen = Time.new(2026, 3, 1, 10, 0, 0, '+00:00')
    expect(keep_chosen_datetime('entries_time_filter_from', chosen)).to eq(chosen.to_i)
  end

  it 'keeps chosen to datetime when checkbox is off' do
    render_component(entry_nodes)
    chosen = Time.new(2026, 3, 1, 18, 0, 0, '+00:00')
    expect(keep_chosen_datetime('entries_time_filter_to', chosen)).to eq(chosen.to_i)
  end

  it 'renders archive icon button and sends archive callback' do
    render_component(entry_nodes)
    click_archive_button
    expect_entry_archived
  end

  private

  def expand_button
    toolbar_button('entries_expand_all')
  end

  def collapse_button
    toolbar_button('entries_collapse_all')
  end

  def toolbar_button(name)
    descendants(parent).grep(QPushButton).find { |button| button.object_name == name }
  end

  def render_component(nodes, show_parent: false)
    component.render(nodes)
    parent.show if show_parent
    QApplication.process_events
  end

  def collapse_all_nodes
    collapse_button.click
    QApplication.process_events
    expect_all_week_buttons_to_start_with('▸')
    expand_button.click
    QApplication.process_events
  end

  def rendered_scroll_area
    component.send(:scroll_area)
  end

  def rendered_host
    component.send(:host)
  end

  def widest_branch_width
    descendants(parent)
      .grep(QPushButton)
      .select { |button| button.object_name.start_with?('entry_node_') }
      .map(&:width)
      .max
  end

  def expect_branch_widths_within_viewport
    expect(rendered_host.width).to be <= rendered_scroll_area.width
    expect(widest_branch_width).to be <= rendered_scroll_area.width
  end

  def week_buttons
    descendants(parent).grep(QPushButton).select { |button| button.object_name == 'entry_node_week' }
  end

  def entry_note_input
    find_line_edit('entry_node_entry_note')
  end

  def entry_start_input
    find_line_edit('entry_node_entry_start')
  end

  def entry_task_input
    descendants(parent).grep(QComboBox).find { |input| input.object_name == 'entry_node_entry_task' }
  end

  def entry_end_input
    find_line_edit('entry_node_entry_end')
  end

  def entry_archive_button
    descendants(parent).grep(QPushButton).find { |button| button.object_name == 'entry_node_entry_archive' }
  end

  def expect_note_input_state(input, text:, read_only:)
    expect(input).not_to be_nil
    expect(input.text.to_s).to eq(text)
    expect(input.is_read_only).to be(read_only)
  end

  def expect_all_week_buttons_to_start_with(marker)
    expect(week_buttons).to all(satisfy { |button| normalized_text(button).lstrip.start_with?(marker) })
  end

  def expect_expanded_state_and_unknown_leaf
    expect_all_week_buttons_to_start_with('▾')
    expect(find_unknown_leaf).not_to be_nil
  end

  def find_unknown_leaf
    descendants(parent).grep(QLabel).find { |label| label.object_name == 'entry_node_empty' }
  end

  def commit_note_input(note_input, text)
    expect_note_input_state(note_input, text: 'test', read_only: true)
    component.send(:activate_entry_note_input, note_input)
    note_input.text = text
    component.send(:handle_entry_note_key_press, note_input, 1, { a: Qt::Key_Return })
    expect_note_commit
  end

  def expect_note_commit
    expect(entry_note_input.is_read_only).to be(true)
  end

  def expect_task_input_state(task_input)
    expect(task_input).not_to be_nil
    expect(task_input.current_text.to_s).to eq('core')
    expect(task_combo_items(task_input)).to eq(%w[core ops deploy])
  end

  def commit_entry_task_input(task_name)
    task_input = entry_task_input
    component.send(:activate_entry_task_input, task_input)
    task_input.set_current_text(task_name)
    component.send(:handle_entry_task_key_press, task_input, 1, { a: Qt::Key_Return })
  end

  def expect_task_commit(task_name)
    expect(callbacks.fetch(:on_entry_task_change)).to have_received(:call).with(1, task_name)
    expect(component.send(:entry_task_line_edit, entry_task_input).is_read_only).to be(true)
  end

  def expect_time_inputs(start_input, end_input, start_text:, end_text:, read_only:)
    expect_inputs_present(start_input, end_input)
    expect_input_texts(start_input, end_input, start_text, end_text)
    expect(start_input.is_read_only).to be(read_only)
  end

  def commit_time_input_change(start_input, end_input)
    component.send(:activate_entry_note_input, start_input)
    start_input.text = '10:15'
    commit_time_change(start_input: start_input, end_input: end_input)
    expect_time_commit
  end

  def expect_time_commit
    expect(entry_start_input.is_read_only).to be(true)
  end

  def commit_time_change(start_input:, end_input:)
    component.send(
      :handle_entry_time_key_press,
      time_input: start_input,
      entry_id: 1,
      start_input: start_input,
      end_input: end_input,
      event: { a: Qt::Key_Return }
    )
  end

  def assert_time_input_ignores_commit_while_read_only
    start_input = entry_start_input
    end_input = entry_end_input
    component.send(
      :handle_entry_time_commit,
      time_input: start_input,
      entry_id: 1,
      start_input: start_input,
      end_input: end_input
    )
    expect(callbacks.fetch(:on_entry_time_change)).not_to have_received(:call)
  end

  def time_filter_widgets
    from_toggle = find_checkbox('entries_time_filter_from_toggle')
    to_toggle = find_checkbox('entries_time_filter_to_toggle')
    from_input = find_datetime_input('entries_time_filter_from')
    to_input = find_datetime_input('entries_time_filter_to')
    [from_toggle, to_toggle, from_input, to_input]
  end

  def find_checkbox(object_name)
    descendants(parent).grep(QCheckBox).find { |button| button.object_name == object_name }
  end

  def expect_time_filter_widgets(from_toggle, to_toggle, from_input, to_input)
    expect(from_toggle).not_to be_nil
    expect(to_toggle).not_to be_nil
    expect(from_input).not_to be_nil
    expect(to_input).not_to be_nil
  end

  def apply_time_filter_values(from_toggle, to_toggle, from_input, to_input)
    from_toggle.click
    to_toggle.click
    from_input.set_date_time(Time.new(2026, 3, 1, 10, 0, 0, '+00:00'))
    to_input.set_date_time(Time.new(2026, 3, 1, 18, 0, 0, '+00:00'))
    sleep 0.25
    QApplication.process_events
  end

  def find_line_edit(object_name)
    descendants(parent).grep(QLineEdit).find { |input| input.object_name == object_name }
  end

  def task_combo_items(task_input)
    (0...task_input.count).map { |index| task_input.item_text(index).to_s }
  end

  def expect_empty_note_placeholder_on_activation
    note_input = entry_note_input
    component.send(:activate_entry_note_input, note_input)
    expect_note_placeholder_state(note_input, read_only: false)
  end

  def expect_empty_note_placeholder_on_deactivation
    note_input = entry_note_input
    component.send(:activate_entry_note_input, note_input)
    component.send(:handle_entry_note_focus_out, note_input)
    expect_note_placeholder_state(note_input, read_only: true)
  end

  def expect_note_placeholder_state(note_input, read_only:)
    expect(note_input.text.to_s).to eq('')
    expect(note_input.placeholder_text.to_s).to eq('(no note)')
    expect(note_input.is_read_only).to be(read_only)
  end

  def deactivate_note_input_without_commit
    note_input = entry_note_input
    component.send(:activate_entry_note_input, note_input)
    note_input.text = 'changed but not committed'
    component.send(:handle_entry_note_focus_out, note_input)
  end

  def expect_note_not_committed
    expect(entry_note_input.is_read_only).to be(true)
    expect(callbacks.fetch(:on_entry_note_change)).not_to have_received(:call)
  end

  def expect_inputs_present(start_input, end_input)
    expect(start_input).not_to be_nil
    expect(end_input).not_to be_nil
  end

  def expect_input_texts(start_input, end_input, start_text, end_text)
    expect(start_input.text.to_s).to eq(start_text)
    expect(end_input.text.to_s).to eq(end_text)
  end

  def find_datetime_input(object_name)
    descendants(parent).grep(QDateTimeEdit).find { |input| input.object_name == object_name }
  end

  def expect_hash_event_to_match_enter_key
    expect(component.send(:event_key_code, { 'a' => Qt::Key_Return })).to eq(Qt::Key_Return)
    expect(component.send(:enter_key?, { 'a' => Qt::Key_Return })).to be(true)
  end

  def expect_object_event_to_match_enter_key
    event = Struct.new(:key).new(Qt::Key_Enter)
    expect(component.send(:event_key_code, event)).to eq(Qt::Key_Enter)
    expect(component.send(:enter_key?, event)).to be(true)
  end

  def apply_time_filter_widget_values
    from_toggle, to_toggle, from_input, to_input = time_filter_widgets
    expect_time_filter_widgets(from_toggle, to_toggle, from_input, to_input)
    apply_time_filter_values(from_toggle, to_toggle, from_input, to_input)
  end

  def expect_nil_time_range_change
    expect_time_inputs_enabled
    component.send(:emit_time_range_filter_changed)
    expect(callbacks.fetch(:on_time_range_change)).to have_received(:call).with(nil, nil).at_least(:once)
  end

  def expect_time_inputs_enabled
    expect(find_datetime_input('entries_time_filter_from').is_enabled).to be(true)
    expect(find_datetime_input('entries_time_filter_to').is_enabled).to be(true)
  end

  def keep_chosen_datetime(object_name, chosen)
    input = find_datetime_input(object_name)
    input.set_date_time(chosen)
    QApplication.process_events
    component.update_time_range_inputs(from_at: nil, to_at: nil)
    QApplication.process_events
    input.date_time.to_i
  end

  def click_archive_button
    archive_button = entry_archive_button
    expect(archive_button).not_to be_nil
    archive_button.click
  end

  def expect_entry_archived
    expect(callbacks.fetch(:on_entry_archive)).to have_received(:call).with(1)
  end

  def normalized_text(button)
    text = button.text.to_s.dup
    return text unless text.encoding == Encoding::BINARY

    text.force_encoding(Encoding::UTF_8)
  end

  def entry_nodes
    [
      {
        id: 'week:1',
        type: :week,
        label: 'Week Feb 23 - Mar 1  Total: 01:00:00',
        children: [
          {
            id: 'day:1',
            type: :day,
            label: 'Sun, Mar 1  Total: 01:00:00',
            children: [
              {
                id: 'project:1',
                type: :project,
                label: 'acme | core (1) 01:00:00',
                children: [
                  {
                    id: 'entry:1',
                    type: :entry,
                    entry_id: 1,
                    project_name: 'acme',
                    task_name: 'core',
                    start_label: '10:00',
                    end_label: '11:00',
                    prefix: '01:00:00',
                    note: 'test',
                    label: '10:00 - 11:00  01:00:00  test',
                    children: []
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        id: 'misc:1',
        type: :unknown_type,
        label: 'mystery node',
        children: []
      }
    ]
  end

  def long_label_nodes
    [
      {
        id: 'week:long',
        type: :week,
        label: "Week #{'X' * 300}",
        children: [
          {
            id: 'day:long',
            type: :day,
            label: "Day #{'Y' * 300}",
            children: [
              {
                id: 'project:long',
                type: :project,
                label: "Project #{'Z' * 300}",
                children: [
                  { id: 'entry:long', type: :entry, label: 'entry', children: [] }
                ]
              }
            ]
          }
        ]
      }
    ]
  end

  def no_note_entry_nodes
    [
      {
        id: 'week:no-note',
        type: :week,
        label: 'Week Feb 23 - Mar 1  Total: 00:05:00',
        children: [
          {
            id: 'day:no-note',
            type: :day,
            label: 'Sun, Mar 1  Total: 00:05:00',
            children: [
              {
                id: 'project:no-note',
                type: :project,
                label: 'acme | task (1) 00:05:00',
                children: [
                  {
                    id: 'entry:no-note',
                    type: :entry,
                    entry_id: 11,
                    project_name: 'acme',
                    task_name: 'task',
                    start_label: '10:00',
                    end_label: '10:05',
                    prefix: '00:05:00',
                    note: '',
                    label: '10:00 - 10:05  00:05:00  (no note)',
                    children: []
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  end

  def descendants(widget)
    children = safe_children(widget)
    children + children.flat_map { |child| descendants(child) }
  end

  def safe_children(widget)
    return [] unless widget.respond_to?(:children)

    Array(widget.children).compact
  rescue NoMethodError
    []
  end
end
