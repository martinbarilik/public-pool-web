# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'

class PullHrJobTest < ActiveSupport::TestCase
	include ActiveSupport::Testing::TimeHelpers

	fixtures :users, :workers, :pools, :chart_datas

	setup do
		@user = users(:one)
		@worker = workers(:bitaxe)
		@pool = pools(:one)
		@current_time = Time.zone.parse('2025-04-06 20:27:27')

		@api_response = {
			bestDifficulty: 122_980_611.03298214,
			workersCount: 1,
			workers: [
				{
					sessionId: '0597ca18',
					name: @worker.name,
					bestDifficulty: '50681663.86',
					hashRate: 836_956_701_106,
					startTime: '2025-03-01T15:49:29.000Z',
					lastSeen: '2025-03-02T13:39:19.000Z'
				}
			]
		}.to_json
	end

	test 'successful update of worker data' do
		stub_request(:get, "http://#{@pool.host}:#{@pool.port}/api/client/#{@user.name}")
			.to_return(status: 200, body: @api_response)

		assert_difference -> { @worker.chart_datas.count }, 1 do
			PullHrJob.new.perform
		end

		@worker.reload
		assert_equal '0597ca18', @worker.session_id
		assert_equal 50681663.86, @worker.best_difficulty
		assert_equal 836_956_701_106, @worker.hash_rate
		assert_equal Time.zone.parse('2025-03-01T15:49:29.000Z'), @worker.start_time
		assert_equal Time.zone.parse('2025-03-02T13:39:19.000Z'), @worker.last_seen

		@user.reload
		assert_equal 122_980_611.03298214, @user.best_difficulty
		assert_equal 1, @user.workers_count

		@pool.reload
		assert_equal 122_980_611.03298214, @pool.best_difficulty
		assert_equal 1, @pool.workers_count
	end

	test 'skips duplicate chart data within interval' do
		stub_request(:get, "http://#{@pool.host}:#{@pool.port}/api/client/#{@user.name}")
			.to_return(status: 200, body: @api_response)

		travel_to @current_time do
			# Create recent chart data
			@worker.chart_datas.create!(
				label: 8.minutes.ago,
				data: 836_956_701_106
			)

			assert_no_difference -> { @worker.chart_datas.count } do
				PullHrJob.new.perform
			end
		end
	end

	test 'handles HTTP error gracefully' do
		stub_request(:get, "http://#{@pool.host}:#{@pool.port}/api/client/#{@user.name}")
			.to_return(status: 500, body: 'Internal Server Error')

		assert_no_difference -> { @worker.chart_datas.count } do
			PullHrJob.new.perform
		end
	end

	test 'handles invalid JSON response' do
		stub_request(:get, "http://#{@pool.host}:#{@pool.port}/api/client/#{@user.name}")
			.to_return(status: 200, body: 'Invalid JSON')

		assert_no_difference -> { @worker.chart_datas.count } do
			PullHrJob.new.perform
		end
	end

	test 'handles timeout error' do
		stub_request(:get, "http://#{@pool.host}:#{@pool.port}/api/client/#{@user.name}")
			.to_timeout

		assert_no_difference -> { @worker.chart_datas.count } do
			PullHrJob.new.perform
		end
	end

	test 'handles missing worker gracefully' do
		api_response = {
			bestDifficulty: 122_980_611.03298214,
			workersCount: 1,
			workers: [
				{
					sessionId: '0597ca18',
					name: 'nonexistent_worker',
					bestDifficulty: '50681663.86',
					hashRate: 836_956_701_106,
					startTime: '2025-03-01T15:49:29.000Z',
					lastSeen: '2025-03-02T13:39:19.000Z'
				}
			]
		}.to_json

		stub_request(:get, "http://#{@pool.host}:#{@pool.port}/api/client/#{@user.name}")
			.to_return(status: 200, body: api_response)

		assert_no_difference -> { @worker.chart_datas.count } do
			PullHrJob.new.perform
		end
	end
end
