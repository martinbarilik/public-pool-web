# frozen_string_literal: true

require 'test_helper'

class ChartDataTest < ActiveSupport::TestCase
	setup do
		@worker = workers(:bitaxe)
		@worker2 = workers(:bitaxe2)
		@chart_data = chart_datas(:one)

		# Create additional test data
		ChartData.create!(
			worker: @worker,
			label: 45.minutes.ago,
			data: 500_000_000_000
		)

		ChartData.create!(
			worker: @worker2,
			label: 45.minutes.ago,
			data: 1_000_000_000_000
		)
	end

	test 'belongs to worker' do
		assert_respond_to @chart_data, :worker
		assert_instance_of Worker, @chart_data.worker
	end

	test 'chart_data returns empty array for unsupported interval' do
		result = ChartData.chart_data(since: 2.days.ago)
		assert_empty result
	end

	test 'chart_data returns data for 1 hour interval' do
		result = ChartData.chart_data(since: 1.hour.ago)
		assert_instance_of Array, result
		assert_equal 1, result.size
		assert(result.all? { |point| point.is_a?(ChartDataPt1hView) && point.data == 1_500_000_000_000 })
	end

	test 'chart_data filters by worker_id' do
		result = ChartData.chart_data(since: 1.hour.ago, worker_id: @worker.id)
		assert_instance_of Array, result
		assert_equal 1, result.size
		assert(result.all? { |point| point.is_a?(ChartDataPt1hView) && point.data == 500_000_000_000 })
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
