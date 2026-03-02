# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Entries::ListComponent do
  include_context :qt

  let(:parent) { QWidget.new }
  let(:on_entry_note_change) { instance_double(Proc, call: nil) }
  let(:on_entry_time_change) { instance_double(Proc, call: nil) }
  let(:on_time_range_change) { instance_double(Proc, call: nil) }
  let(:component) do
    described_class.new(
      parent: parent,
      on_entry_note_change: on_entry_note_change,
      on_entry_time_change: on_entry_time_change,
      on_time_range_change: on_time_range_change
    )
  end
  let(:widget) { component.widget }

  after do
    parent.close if parent.respond_to?(:close)
    QApplication.process_events
  end

  it 'applies expand/collapse all recursively and renders unknown leaf type as empty node style' do
    component.render(entry_nodes)
    QApplication.process_events

    collapse_button.click
    QApplication.process_events
    expect(week_buttons).to all(satisfy { |button| normalized_text(button).lstrip.start_with?('▸') })

    expand_button.click
    QApplication.process_events
    expect(week_buttons).to all(satisfy { |button| normalized_text(button).lstrip.start_with?('▾') })

    unknown_leaf = descendants(parent).grep(QLabel).find { |label| label.object_name == 'entry_node_empty' }
    expect(unknown_leaf).not_to be_nil
  end

  it 'keeps branch nodes inside scroll viewport width for long labels' do
    parent.resize(920, 720)
    component.render(long_label_nodes)
    parent.show
    QApplication.process_events

    scroll_area = component.send(:scroll_area)
    host = component.send(:host)

    widest_branch = descendants(parent)
                    .grep(QPushButton)
                    .select { |button| button.object_name.start_with?('entry_node_') }
                    .map(&:width)
                    .max

    expect(host.width).to be <= scroll_area.width
    expect(widest_branch).to be <= scroll_area.width
  end

  it 'activates note input on click and commits only on Enter' do
    component.render(entry_nodes)
    QApplication.process_events

    note_input = descendants(parent).grep(QLineEdit).find { |input| input.object_name == 'entry_node_entry_note' }
    expect(note_input).not_to be_nil
    expect(note_input.text.to_s).to eq('test')
    expect(note_input.is_read_only).to be(true)

    component.send(:activate_entry_note_input, note_input)
    expect(note_input.is_read_only).to be(false)

    note_input.text = 'updated note'
    component.send(:handle_entry_note_key_press, note_input, 1, { a: Qt::Key_Return })

    expect(note_input.is_read_only).to be(true)
    expect(on_entry_note_change).to have_received(:call).with(1, 'updated note')
  end

  it 'renders start/end inputs for entry rows' do
    component.render(entry_nodes)
    QApplication.process_events

    start_input = descendants(parent).grep(QLineEdit).find { |input| input.object_name == 'entry_node_entry_start' }
    end_input = descendants(parent).grep(QLineEdit).find { |input| input.object_name == 'entry_node_entry_end' }
    expect(start_input).not_to be_nil
    expect(end_input).not_to be_nil
    expect(start_input.text.to_s).to eq('10:00')
    expect(end_input.text.to_s).to eq('11:00')
    expect(start_input.is_read_only).to be(true)
  end

  it 'commits edited start/end values on Enter' do
    component.render(entry_nodes)
    QApplication.process_events

    start_input = descendants(parent).grep(QLineEdit).find { |input| input.object_name == 'entry_node_entry_start' }
    end_input = descendants(parent).grep(QLineEdit).find { |input| input.object_name == 'entry_node_entry_end' }

    component.send(:activate_entry_note_input, start_input)
    expect(start_input.is_read_only).to be(false)

    start_input.text = '10:15'
    component.send(
      :handle_entry_time_key_press,
      time_input: start_input,
      entry_id: 1,
      start_input: start_input,
      end_input: end_input,
      event: { a: Qt::Key_Return }
    )

    expect(start_input.is_read_only).to be(true)
    expect(on_entry_time_change).to have_received(:call).with(1, '10:15', '11:00')
  end

  it 'does not commit time when input is already read-only' do
    component.render(entry_nodes)
    QApplication.process_events

    start_input = descendants(parent).grep(QLineEdit).find { |input| input.object_name == 'entry_node_entry_start' }
    end_input = descendants(parent).grep(QLineEdit).find { |input| input.object_name == 'entry_node_entry_end' }

    expect(start_input.is_read_only).to be(true)
    component.send(
      :handle_entry_time_commit,
      time_input: start_input,
      entry_id: 1,
      start_input: start_input,
      end_input: end_input
    )

    expect(on_entry_time_change).not_to have_received(:call)
  end

  it 'deactivates note input on focus loss without committing' do
    component.render(entry_nodes)
    QApplication.process_events

    note_input = descendants(parent).grep(QLineEdit).find { |input| input.object_name == 'entry_node_entry_note' }
    component.send(:activate_entry_note_input, note_input)
    note_input.text = 'changed but not committed'

    component.send(:handle_entry_note_focus_out, note_input)

    expect(note_input.is_read_only).to be(true)
    expect(on_entry_note_change).not_to have_received(:call)
  end

  it 'uses native placeholder for empty note and keeps text empty on activation' do
    component.render(no_note_entry_nodes)
    QApplication.process_events

    note_input = descendants(parent).grep(QLineEdit).find { |input| input.object_name == 'entry_node_entry_note' }
    expect(note_input.text.to_s).to eq('')
    expect(note_input.placeholder_text.to_s).to eq('(no note)')

    component.send(:activate_entry_note_input, note_input)

    expect(note_input.is_read_only).to be(false)
    expect(note_input.text.to_s).to eq('')
  end

  it 'keeps native placeholder on deactivation when input is blank' do
    component.render(no_note_entry_nodes)
    QApplication.process_events

    note_input = descendants(parent).grep(QLineEdit).find { |input| input.object_name == 'entry_node_entry_note' }
    component.send(:activate_entry_note_input, note_input)
    expect(note_input.text.to_s).to eq('')

    component.send(:handle_entry_note_focus_out, note_input)

    expect(note_input.is_read_only).to be(true)
    expect(note_input.text.to_s).to eq('')
    expect(note_input.placeholder_text.to_s).to eq('(no note)')
  end

  it 'extracts enter key code from hash payload with string key' do
    expect(component.send(:event_key_code, { 'a' => Qt::Key_Return })).to eq(Qt::Key_Return)
    expect(component.send(:enter_key?, { 'a' => Qt::Key_Return })).to be(true)
  end

  it 'extracts key code from event object responding to key' do
    event = Struct.new(:key).new(Qt::Key_Enter)

    expect(component.send(:event_key_code, event)).to eq(Qt::Key_Enter)
    expect(component.send(:enter_key?, event)).to be(true)
  end

  it 'renders toolbar date-time range controls and auto-applies filter callback' do
    component.render(entry_nodes)
    QApplication.process_events

    from_toggle = descendants(parent).grep(QCheckBox).find do |button|
      button.object_name == 'entries_time_filter_from_toggle'
    end
    to_toggle = descendants(parent).grep(QCheckBox).find do |button|
      button.object_name == 'entries_time_filter_to_toggle'
    end
    from_input = descendants(parent).grep(QDateTimeEdit).find do |input|
      input.object_name == 'entries_time_filter_from'
    end
    to_input = descendants(parent).grep(QDateTimeEdit).find { |input| input.object_name == 'entries_time_filter_to' }
    expect(from_toggle).not_to be_nil
    expect(to_toggle).not_to be_nil
    expect(from_input).not_to be_nil
    expect(to_input).not_to be_nil

    from_toggle.click
    to_toggle.click
    from_value = Time.new(2026, 3, 1, 10, 0, 0, '+00:00')
    to_value = Time.new(2026, 3, 1, 18, 0, 0, '+00:00')
    from_input.set_date_time(from_value)
    to_input.set_date_time(to_value)
    sleep 0.25
    QApplication.process_events

    expect(on_time_range_change).to have_received(:call).with(kind_of(Time), kind_of(Time)).at_least(:once)
  end

  it 'sends nil range when both date-time checkboxes are off' do
    component.render(entry_nodes)
    QApplication.process_events

    from_input = descendants(parent).grep(QDateTimeEdit).find { |input| input.object_name == 'entries_time_filter_from' }
    to_input = descendants(parent).grep(QDateTimeEdit).find { |input| input.object_name == 'entries_time_filter_to' }
    expect(from_input.is_enabled).to eq(true)
    expect(to_input.is_enabled).to eq(true)

    component.send(:emit_time_range_filter_changed)

    expect(on_time_range_change).to have_received(:call).with(nil, nil).at_least(:once)
  end

  it 'keeps chosen from datetime when checkbox is off' do
    component.render(entry_nodes)
    QApplication.process_events

    from_input = descendants(parent).grep(QDateTimeEdit).find { |input| input.object_name == 'entries_time_filter_from' }
    chosen = Time.new(2026, 3, 1, 10, 0, 0, '+00:00')
    from_input.set_date_time(chosen)
    QApplication.process_events

    component.update_time_range_inputs(from_at: nil, to_at: nil)
    QApplication.process_events

    expect(from_input.date_time.to_i).to eq(chosen.to_i)
  end

  it 'keeps chosen to datetime when checkbox is off' do
    component.render(entry_nodes)
    QApplication.process_events

    to_input = descendants(parent).grep(QDateTimeEdit).find { |input| input.object_name == 'entries_time_filter_to' }
    chosen = Time.new(2026, 3, 1, 18, 0, 0, '+00:00')
    to_input.set_date_time(chosen)
    QApplication.process_events

    component.update_time_range_inputs(from_at: nil, to_at: nil)
    QApplication.process_events

    expect(to_input.date_time.to_i).to eq(chosen.to_i)
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

  def week_buttons
    descendants(parent).grep(QPushButton).select { |button| button.object_name == 'entry_node_week' }
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
