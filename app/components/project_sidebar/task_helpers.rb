# frozen_string_literal: true

module QTimetrap
  module ProjectSidebar
    # Sidebar tasks section rendering and interactions.
    module TaskHelpers
      include TaskSelectionHelpers

      private

      def render_tasks(tasks:, selected_project:, selected_task:)
        values = Array(tasks)
        visible = tasks_visible?(selected_project, values)
        tasks_heading.set_visible(visible)
        sync_task_buttons(visible ? values.size : 0)
        return clear_task_state unless visible

        refresh_task_state(values, selected_task)
        fill_task_buttons(values)
      end

      def sync_task_buttons(target_count)
        while task_buttons.size < target_count
          button = build_task_button
          task_buttons_layout.add_widget(button)
          task_buttons << { view: button, task: nil }
        end

        while task_buttons.size > target_count
          slot = task_buttons.pop
          slot.fetch(:view).hide
        end
      end

      def build_tasks_heading
        QLabel.new(widget).tap do |label|
          label.set_object_name('sidebar_tasks_heading')
          label.set_alignment(Qt::AlignCenter)
          label.set_text('TASKS')
        end
      end

      def build_task_button
        QPushButton.new(widget).tap do |button|
          button.set_object_name('task_button')
          button.set_checkable(true)
          button.set_focus_policy(Qt::NoFocus)
          button.set_fixed_height(28)
          button.connect('clicked') { |_| on_task_button_clicked(button) }
        end
      end

      def on_task_button_clicked(button)
        index = task_buttons.index { |candidate| candidate[:view] == button }
        return unless index

        item = task_buttons.fetch(index)
        return unless item && item[:task]

        apply_task_selection(index)
        fill_task_buttons(task_values)
        return unless on_task_selected

        on_task_selected.call(selected_task_values, item[:task])
      end

      def tasks_visible?(selected_project, values)
        selected_project != '* ALL' && !values.empty?
      end

      def fill_task_buttons(values)
        task_buttons.each_with_index do |slot, index|
          update_task_button(slot: slot, task: values[index], index: index)
        end
      end

      def update_task_button(slot:, task:, index:)
        view = slot.fetch(:view)
        slot[:task] = task
        text = task.to_s
        view.set_text(text)
        view.set_tool_tip(text)
        view.set_checked(selected_task_indices.include?(index))
        view.show
      end

      def selected_task_values
        selected_task_indices.filter_map { |index| task_values[index] }
      end

      attr_reader :selected_task_indices, :last_task_anchor_index, :task_values
    end
  end
end
