# frozen_string_literal: true

module QTimetrap
  module Services
    # Note update workflow for Timetrap API/CLI adapters.
    module TimetrapGatewayUpdateNoteHelpers
      def update_note(entry_id, note)
        normalized_id = entry_id.to_i
        normalized_note = normalize_text(note).strip
        return if normalized_id.zero?

        if api_available?
          logger.log_api(
            operation: 'update_note',
            input: { entry_id: normalized_id, note: normalized_note },
            output: 'requested'
          )
          result = update_note_via_api(normalized_id, normalized_note)
          logger.log_api(operation: 'update_note', input: {}, output: result.to_s)
          return result
        end

        update_note_via_cli(normalized_id, normalized_note)
      end

      private

      def update_note_via_api(entry_id, note)
        entry = resolve_entry_for_note_update(Timetrap::Entry[entry_id])
        entry.note = note
        entry.save
      end

      def update_note_via_cli(entry_id, note)
        return run('edit', '--id', entry_id.to_s, '--clear') if note.empty?

        run('edit', '--id', entry_id.to_s, note)
      end

      def resolve_entry_for_note_update(value)
        entry = value
        raise TypeError, "Unsupported entry lookup result: #{value.class}" unless entry

        entry
      end
    end
  end
end
