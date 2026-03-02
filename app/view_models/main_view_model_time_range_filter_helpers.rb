# frozen_string_literal: true

module QTimetrap
  module ViewModels
    # Date-time range filter behavior for MainViewModel.
    module MainViewModelTimeRangeFilterHelpers
      def update_time_range_filter(from_at:, to_at:)
        validate_time_range!(from_at, to_at)
        @time_filter_from_at = from_at
        @time_filter_to_at = to_at
      end

      private

      def validate_time_range!(from_at, to_at)
        return unless from_at && to_at
        return unless from_at > to_at

        raise ArgumentError, 'Date-time filter FROM must be less than or equal to TO'
      end
    end
  end
end
