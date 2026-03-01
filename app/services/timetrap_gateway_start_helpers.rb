# frozen_string_literal: true

module QTimetrap
  module Services
    # Shared start workflow for Timetrap API/CLI adapters.
    module TimetrapGatewayStartHelpers
      private

      def normalize_start_inputs(sheet, checkin_note)
        [normalize_text(sheet).strip, normalize_text(checkin_note).strip]
      end

      def start_via_api(sheet, checkin_note)
        Timetrap::Timer.current_sheet = sheet
        Timetrap::Timer.start(checkin_note)
      end

      def start_via_cli(sheet, checkin_note)
        sheet_ok, = run('sheet', sheet)
        return unless sheet_ok

        return run('in') if checkin_note.empty?

        run('in', checkin_note)
      end
    end
  end
end
