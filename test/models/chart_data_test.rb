# frozen_string_literal: true

require 'test_helper'

class ChartDataTest < ActiveSupport::TestCase
	setup do
		@worker = workers(:bitaxe)
		@chart_data = chart_datas(:one)
		@time_now = Time.zone.now

		# Create additional test data
		ChartData.create!(
			worker: @worker,
			label: 45.minutes.ago,
			data: 35.0
		)
	end

	test 'belongs to worker' do
		assert_respond_to @chart_data, :worker
		assert_instance_of Worker, @chart_data.worker
	end

	test 'ungrouped_data scope requires since parameter' do
		assert_raises(ArgumentError) do
			ChartData.ungrouped_data(nil, nil)
		end
	end

	test 'ungrouped_data scope returns data since given time' do
		since_time = 1.hour.ago
		result = ChartData.ungrouped_data(since_time, nil)

		assert_not_empty result
		assert(result.all? { |data| data.label >= since_time })
	end

	test 'ungrouped_data scope filters by worker_id when provided' do
		since_time = 1.hour.ago
		result = ChartData.ungrouped_data(since_time, @worker.id)

		assert_not_empty result
		assert(result.all? { |data| data.worker_id == @worker.id })
	end

	test 'chart_data returns empty array for unsupported interval' do
		result = ChartData.chart_data(since: 2.days.ago)
		assert_empty result
	end

	test 'chart_data returns data for 1 hour interval' do
		result = ChartData.chart_data(since: 1.hour.ago)
		assert_instance_of Array, result
		assert(result.all? { |point| point.is_a?(Array) && point.size == 2 })
	end

	test 'chart_data filters by worker_id' do
		result = ChartData.chart_data(since: 1.hour.ago, worker_id: @worker.id)
		assert_instance_of Array, result
	end

	test 'broadcasts chart update after create' do
		new_data = ChartData.new(
			worker: @worker,
			label: Time.current,
			data: 42.0
		)

		# Create a pool for the broadcast
		Pool.first_or_create # Required for the broadcast to work

		# The broadcast channel is based on the worker's chart_datas dom_id
		channel = dom_id(@worker, 'chart_datas')
		assert_broadcasts(channel, 1) do
			new_data.save!
		end
	end

	test 'supported intervals are valid ISO 8601 durations' do
		ChartData::SUPPORTED_INTERVALS.each do |interval|
			assert_nothing_raised do
				ActiveSupport::Duration.parse(interval)
			end
		end
	end
end
