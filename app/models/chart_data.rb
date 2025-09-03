# frozen_string_literal: true

# ChartData handles time-series data processing and visualization for worker statistics.
# It provides functionality for data aggregation, grouping, and real-time updates through
# ActionCable broadcasts.
class ChartData < ApplicationRecord
	include ActionView::RecordIdentifier

	belongs_to :worker

	# Configuration constants
	TOLERANCE = 1.second
	SUPPORTED_INTERVALS = %w[PT1H PT4H PT24H P7D].freeze
	DEFAULT_TIMEFRAME = 1.hour
	COLOR = '#dc3545'
	GRID_COLOR = '#555'
	FONT_SIZE = 12
	OFFSET = 6.25

	# Callbacks
	after_create_commit :broadcast_chart_update

	# Class methods
	class << self
		# Processes and returns chart data based on the specified timeframe and worker
		# @param since [Time] the starting point for data collection
		# @param worker_id [Integer, nil] optional worker filter
		# @return [Array<Array>] processed chart data points
		def chart_data(since: DEFAULT_TIMEFRAME.ago, worker_id: nil)
			SUPPORTED_INTERVALS.each do |duration|
				next unless duration_matches?(since, duration)

				data = "ChartData#{duration.capitalize}View"
					.constantize
					.select(
							'interval_label, ' \
							'SUM(avg_data) as data'
						)
					.group(:interval_label)
					.order(:interval_label)

				data = data.group(:worker_id).having(worker_id:) if worker_id.present?

				return data.to_a
			end

			# Return empty array if no matching interval found
			[]
		end

		private

		def duration_matches?(since, duration)
			(since - parse_duration(duration).ago).abs < TOLERANCE
		end

		def parse_duration(duration)
			ActiveSupport::Duration.parse(duration)
		end
	end

	private

	def broadcast_chart_update
		broadcast_replace_to(
			dom_id(worker, 'chart_datas'),
			target: dom_id(worker, 'chart_datas'),
			template: 'chart_datas/index',
			locals: {
				pool: Pool.first_or_create,
				worker_id: worker.id
			}
		)
	end
end
