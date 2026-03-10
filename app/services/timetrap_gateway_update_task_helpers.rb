# frozen_string_literal: true

module QTimetrap
  module Services
    # Task/sheet move workflow for Timetrap API/CLI adapters.
    module TimetrapGatewayUpdateTaskHelpers
      def update_task(entry_id, sheet)
        normalized_id = entry_id.to_i
        normalized_sheet = normalize_text(sheet).strip
        return if normalized_id.zero?

        validate_target_sheet!(normalized_sheet)
        return update_task_via_api_logged(normalized_id, normalized_sheet) if api_available?

        update_task_via_cli(normalized_id, normalized_sheet)
      end

      private

      def validate_target_sheet!(sheet)
        raise ArgumentError, 'Sheet is required' if sheet.empty?
      end

      def update_task_via_api_logged(entry_id, sheet)
        logger.log_api(
          operation: 'update_task',
          input: { entry_id: entry_id, sheet: sheet },
          output: 'requested'
        )
        result = update_task_via_api(entry_id, sheet)
        logger.log_api(operation: 'update_task', input: {}, output: result.to_s)
        result
      end

      def update_task_via_api(entry_id, sheet)
        entry = resolve_entry_for_note_update(Timetrap::Entry[entry_id])
        active_entry = Timetrap::Timer.active_entry
        Timetrap::Timer.current_sheet = sheet if active_entry&.id.to_i == entry.id.to_i
        entry.update(sheet: sheet)
      end

      def update_task_via_cli(entry_id, sheet)
        run('edit', '--id', entry_id.to_s, '--move', sheet)
      end
    end
  end
end
