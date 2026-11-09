# frozen_string_literal: true

module QTimetrap
  module Entries
    # Builds editable entry rows in small GUI-thread steps.
    module EntryRowRenderHelpers
      private

      def start_entry_row_render(node, level, layout:, parent_widget:)
        row = build_entry_row(parent_widget)
        apply_entry_widget_styles(row, ListComponent::ENTRY_ROW_STYLE_IDS)
        row_layout = build_entry_row_layout(row)
        layout.add_widget(row)
        entry_rows << row
        entry_id = node.fetch(:entry_id, node.fetch(:id))
        entry_rows_by_id[entry_id] = row
        project_branch_id = container_branch_ids[parent_widget.handle.address]
        entry_row_parent_branches[entry_id] = project_branch_id
        project_branch_entry_ids[project_branch_id] << entry_id if project_branch_id
        row_visible = visible_entry_ids.nil? || visible_entry_ids.key?(entry_id)
        row_filter_state[entry_id] = row_visible
        row.visible = row_visible

        context = {
          node: node,
          level: level,
          row: row,
          row_layout: row_layout,
          parent_layout: layout,
          parent_widget: parent_widget
        }
        enqueue_entry_row_stage(context, :time_group)
      end

      def enqueue_entry_row_stage(context, stage, index = nil)
        render_queue << [:entry_stage, stage, context, index]
      end

      def process_entry_row_stage(context, stage, index)
        case stage
        when :time_group then create_entry_time_group(context)
        when :start_time then create_entry_start_time(context)
        when :time_separator then create_entry_time_separator(context)
        when :end_time then create_entry_end_time(context)
        when :bind_start_time then bind_entry_start_time(context)
        when :bind_end_time then bind_entry_end_time(context)
        when :prefix then create_entry_prefix(context)
        when :task_container then create_task_container(context)
        when :task_display then create_task_display(context)
        when :task_editor then create_task_editor(context)
        when :task_options then add_task_option(context, index)
        when :task_current_text then set_task_current_text(context)
        when :task_bind_display then bind_task_display(context)
        when :task_bind_key then bind_task_key(context)
        when :task_bind_return then bind_task_return(context)
        when :task_bind_focus then bind_task_focus(context)
        when :task_bind_activated then bind_task_activated(context)
        when :note_input then create_entry_note(context)
        when :note_bind_mouse then bind_entry_note_mouse(context)
        when :note_bind_key then bind_entry_note_key(context)
        when :note_bind_return then bind_entry_note_return(context)
        when :note_bind_focus then bind_entry_note_focus(context)
        when :archive_button then create_entry_archive_button(context)
        when :finish then finish_entry_row(context)
        end
      end

      def create_entry_time_group(context)
        group = QWidget.new(context.fetch(:row))
        group.object_name = 'entry_node_entry_time_group'
        layout = QHBoxLayout.new(group)
        layout.set_contents_margins(0, 0, 0, 0)
        layout.spacing = 4
        context[:time_group] = group
        context[:time_layout] = layout
        context.fetch(:row_layout).add_widget(group)
        enqueue_entry_row_stage(context, :start_time)
      end

      def create_entry_start_time(context)
        node = context.fetch(:node)
        input = build_entry_time_input(
          context.fetch(:row),
          object_name: 'entry_node_entry_start',
          value: node.fetch(:start_label, '--:--'),
          placeholder: '--:--'
        )
        context[:start_input] = input
        context.fetch(:time_layout).add_widget(input)
        enqueue_entry_row_stage(context, :time_separator)
      end

      def create_entry_time_separator(context)
        separator = build_entry_time_separator(context.fetch(:time_group))
        context[:time_layout].add_widget(separator)
        enqueue_entry_row_stage(context, :end_time)
      end

      def create_entry_end_time(context)
        node = context.fetch(:node)
        input = build_entry_time_input(
          context.fetch(:row),
          object_name: 'entry_node_entry_end',
          value: node.fetch(:end_label, 'running'),
          placeholder: 'running'
        )
        context[:end_input] = input
        context.fetch(:time_layout).add_widget(input)
        enqueue_entry_row_stage(context, :bind_start_time)
      end

      def bind_entry_start_time(context)
        bind_single_time_input(
          context.fetch(:start_input),
          resolve_entry_id(context.fetch(:node)),
          context.fetch(:start_input),
          context.fetch(:end_input)
        )
        enqueue_entry_row_stage(context, :bind_end_time)
      end

      def bind_entry_end_time(context)
        bind_single_time_input(
          context.fetch(:end_input),
          resolve_entry_id(context.fetch(:node)),
          context.fetch(:start_input),
          context.fetch(:end_input)
        )
        enqueue_entry_row_stage(context, :prefix)
      end

      def create_entry_prefix(context)
        label = build_entry_prefix_label(context.fetch(:row), context.fetch(:node), context.fetch(:level))
        context.fetch(:row_layout).add_widget(label)
        enqueue_entry_row_stage(context, :task_container)
      end

      def create_task_container(context)
        container = QWidget.new(context.fetch(:row))
        container.object_name = 'entry_node_entry_task_container'
        build_entry_task_layout(container)
        context[:task_container] = container
        context.fetch(:row_layout).add_widget(container)
        enqueue_entry_row_stage(context, :task_display)
      end

      def create_task_display(context)
        node = context.fetch(:node)
        task_name = node.fetch(:task_name, '').to_s
        display = build_entry_task_display(context.fetch(:task_container), task_name)
        context[:task_name] = task_name
        context[:task_display] = display
        enqueue_entry_row_stage(context, :task_editor)
      end

      def create_task_editor(context)
        editor, line_edit = build_entry_task_editor_shell(context.fetch(:task_container), context.fetch(:task_name))
        context[:task_editor] = editor
        context[:task_editor_input] = line_edit
        context[:task_options] = task_options_for(context)
        register_task_widgets(context.fetch(:task_container), context.fetch(:task_display), editor, line_edit)
        enqueue_entry_row_stage(context, :task_options, 0)
      end

      def add_task_option(context, index)
        options = context.fetch(:task_options)
        if index < options.length
          context.fetch(:task_editor).add_item(options[index])
          enqueue_entry_row_stage(context, :task_options, index + 1)
        else
          enqueue_entry_row_stage(context, :task_current_text)
        end
      end

      def task_options_for(context)
        node = context.fetch(:node)
        project = node.fetch(:project_name, '').to_s
        suggestions = task_suggestion_cache.fetch(project) do
          task_suggestion_cache[project] = Array(task_suggestions_for_project&.call(project)).map(&:to_s)
        end
        ([context.fetch(:task_name)] + suggestions).reject(&:empty?).uniq
      end

      def set_task_current_text(context)
        context.fetch(:task_editor).current_text = context.fetch(:task_name)
        enqueue_entry_row_stage(context, :task_bind_display)
      end

      def bind_task_display(context)
        task_container = context.fetch(:task_container)
        context.fetch(:task_display).on(:mouse_button_press) { |_| activate_entry_task_input(task_container) }
        enqueue_entry_row_stage(context, :task_bind_key)
      end

      def bind_task_key(context)
        task_container = context.fetch(:task_container)
        entry_id = resolve_entry_id(context.fetch(:node))
        context.fetch(:task_editor_input).on(:key_press) do |event|
          handle_entry_task_key_press(task_container, entry_id, event)
        end
        enqueue_entry_row_stage(context, :task_bind_return)
      end

      def bind_task_return(context)
        task_container = context.fetch(:task_container)
        entry_id = resolve_entry_id(context.fetch(:node))
        context.fetch(:task_editor_input).connect('returnPressed') do |_|
          handle_entry_task_commit(task_container, entry_id)
        end
        enqueue_entry_row_stage(context, :task_bind_focus)
      end

      def bind_task_focus(context)
        task_container = context.fetch(:task_container)
        context.fetch(:task_editor_input).on(:focus_out) { |_| handle_entry_task_focus_out(task_container) }
        enqueue_entry_row_stage(context, :task_bind_activated)
      end

      def bind_task_activated(context)
        task_container = context.fetch(:task_container)
        context.fetch(:task_editor).connect('textActivated') do |_|
          handle_entry_task_commit(task_container, resolve_entry_id(context.fetch(:node)), force: true)
        end
        enqueue_entry_row_stage(context, :note_input)
      end

      def create_entry_note(context)
        input = build_entry_note_input_widget(context.fetch(:row), context.fetch(:node))
        context[:note_input] = input
        context.fetch(:row_layout).add_widget(input)
        enqueue_entry_row_stage(context, :note_bind_mouse)
      end

      def bind_entry_note_mouse(context)
        input = context.fetch(:note_input)
        input.on(:mouse_button_press) { |_| activate_entry_note_input(input) }
        enqueue_entry_row_stage(context, :note_bind_key)
      end

      def bind_entry_note_key(context)
        input = context.fetch(:note_input)
        entry_id = resolve_entry_id(context.fetch(:node))
        input.on(:key_press) { |event| handle_entry_note_key_press(input, entry_id, event) }
        enqueue_entry_row_stage(context, :note_bind_return)
      end

      def bind_entry_note_return(context)
        input = context.fetch(:note_input)
        entry_id = resolve_entry_id(context.fetch(:node))
        input.connect('returnPressed') { |_| handle_entry_note_commit(input, entry_id) }
        enqueue_entry_row_stage(context, :note_bind_focus)
      end

      def bind_entry_note_focus(context)
        context.fetch(:note_input).on(:focus_out) { |_| handle_entry_note_focus_out(context.fetch(:note_input)) }
        enqueue_entry_row_stage(context, :archive_button)
      end

      def create_entry_archive_button(context)
        button = build_entry_archive_button(context.fetch(:row), context.fetch(:node))
        context.fetch(:row_layout).add_widget(button)
        enqueue_entry_row_stage(context, :finish)
      end

      def finish_entry_row(context)
        context.fetch(:row_layout).set_stretch(2, 1)
        context.fetch(:row_layout).set_stretch(3, 2)
      end
    end
  end
end
