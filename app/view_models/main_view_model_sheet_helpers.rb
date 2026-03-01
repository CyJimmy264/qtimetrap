# frozen_string_literal: true

module QTimetrap
  module ViewModels
    # Current sheet/project/task presentation and composition helpers.
    module MainViewModelSheetHelpers
      def current_sheet_label(*)
        current_project_name
      end

      def current_sheet_input
        current_task_input
      end

      def current_project_name
        @current_project_name || project_from_sheet.to_s
      end

      def current_task_input
        @current_task_input || task_from_sheet.to_s
      end

      def current_task_input=(task_name)
        @current_task_input = normalize_text(task_name).strip
      end

      def current_project_name=(project_name)
        @current_project_name = normalize_text(project_name).strip
      end

      def sheet_for_task_input(task_input)
        project = current_project_name
        project = selected_project if project.to_s.empty? && selected_project != '* ALL'
        project = normalize_text(project).strip
        task = normalize_text(task_input).strip
        raise ArgumentError, 'Project is required' if project.empty? || project == '* ALL'
        raise ArgumentError, 'Task is required' if task.empty?

        "#{project}|#{task}"
      end

      private

      def project_from_sheet
        split_current_sheet&.first
      end

      def task_from_sheet
        split_current_sheet&.last.to_s
      end

      def split_current_sheet
        raw = current_sheet.to_s.strip
        return nil if raw.empty?

        if raw.include?('|')
          project, task = raw.split('|', 2).map(&:strip)
          return [project, task]
        end

        [raw, '']
      end

      def seed_current_fields_from_sheet!
        @current_project_name = project_from_sheet.to_s if @current_project_name.nil?
        @current_task_input = task_from_sheet.to_s if @current_task_input.nil?
      end

      def apply_selected_project_to_current_field!
        @current_project_name = selected_project == '* ALL' ? project_from_sheet.to_s : selected_project.to_s
      end
    end
  end
end
