# frozen_string_literal: true

module QTimetrap
  module Components
    # Sidebar tasks section rendering and interactions.
    module ProjectSidebarTaskHelpers
      private

      def render_tasks(tasks:, selected_project:, selected_task:)
        values = Array(tasks)
        visible = tasks_visible?(selected_project, values)
        tasks_heading.set_visible(visible)
        sync_task_buttons(visible ? values.size : 0)
        return unless visible

        fill_task_buttons(values, selected_task)
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
          button.set_fixed_height(28)
          button.connect('clicked') { |_| on_task_button_clicked(button) }
        end
      end

      def on_task_button_clicked(button)
        item = task_buttons.find { |candidate| candidate[:view] == button }
        return unless item && item[:task]
        return unless on_task_selected

        on_task_selected.call(item[:task])
      end

      def tasks_visible?(selected_project, values)
        selected_project != '* ALL' && !values.empty?
      end

      def fill_task_buttons(values, selected_task)
        task_buttons.each_with_index do |slot, index|
          update_task_button(slot: slot, task: values[index], selected_task: selected_task)
        end
      end

      def update_task_button(slot:, task:, selected_task:)
        view = slot.fetch(:view)
        slot[:task] = task
        view.set_text(task.to_s[0, 24])
        view.set_checked(task == selected_task)
        view.show
      end
    end
  end
end
