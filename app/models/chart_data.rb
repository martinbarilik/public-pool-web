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

	# Scopes
	scope :ungrouped_data, lambda { |since, worker_id|
		raise ArgumentError, 'since parameter is required' if since.nil?

		result = select(:label, :worker_id, :data)
			.where(label: since..)
			.order(:label)

		worker_id.present? ? result.where(worker_id:) : result
	}

	# Callbacks
	after_create_commit :broadcast_chart_update

	# Class methods
	class << self
		# Processes and returns chart data based on the specified timeframe and worker
		# @param since [Time] the starting point for data collection
		# @param worker_id [Integer, nil] optional worker filter
		# @return [Array<Array>] processed chart data points
		def chart_data(since: DEFAULT_TIMEFRAME.ago, worker_id: nil)
			data = fetch_and_process_data(since, worker_id)

			SUPPORTED_INTERVALS.each do |duration|
				next unless duration_matches?(since, duration)

				return process_interval_data(duration, data)
			end

			# Return empty array if no matching interval found
			[]
		end

		private

		def fetch_and_process_data(since, worker_id)
			ungrouped_data(since, worker_id).map do |record|
				record.attributes.values.compact_blank
			end
		end

		def duration_matches?(since, duration)
			(since - parse_duration(duration).ago).abs < TOLERANCE
		end

		def process_interval_data(duration, data)
			map_average_values(group_interval(duration, data))
		end

		def parse_duration(duration)
			ActiveSupport::Duration.parse(duration)
		end

		def group_interval(duration, data)
			interval_size = parse_duration(duration).in_hours.minute.to_i

			data.group_by do |point|
				time, = point
				(time.to_i / interval_size) * interval_size
			end
		end

		def map_average_values(groups)
			groups.map do |label, data|
				grouped_by_worker_id = average_by_worker_id(data)
				[Time.zone.at(label), grouped_by_worker_id.sum(&:last)]
			end
		end

		def average_by_worker_id(data)
			data.group_by { _1[1] }.transform_values do |values|
				numeric_values = values.map { |x| x.last.to_f }
				numeric_values.sum / values.size
			end.to_a
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
