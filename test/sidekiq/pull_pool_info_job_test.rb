# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'

class PullPoolInfoJobTest < ActiveSupport::TestCase
	fixtures :pools

	def setup
		@pool = pools(:one)
	end

	def test_perform_updates_pool_stats_and_network_info
		stub_request(:get, "http://#{@pool.host}:#{@pool.port}/api/info")
			.to_return(status: 200, body: {
				highScores: [
					{ bestDifficulty: 12_345.67 },
					{ bestDifficulty: 1_000.0 }
				]
			}.to_json)

		stub_request(:get, "http://#{@pool.host}:#{@pool.port}/api/network")
			.to_return(status: 200, body: {
				blocks: 954_132,
				difficulty: 83_490_660_325_818_120_000,
				networkhashps: 500_000_000_000_000_000_000
			}.to_json)

		PullPoolInfoJob.new.perform

		@pool.reload
		assert_equal 12_345.67, @pool.best_difficulty.to_f
		assert_equal 954_132, @pool.block_height
		assert_equal 83_490_660_325_818_120_000, @pool.network_difficulty.to_i
		assert_equal 500_000_000_000_000_000_000, @pool.network_hash.to_i
	end

	def test_perform_handles_api_errors
		stub_request(:get, "http://#{@pool.host}:#{@pool.port}/api/info")
			.to_return(status: 500, body: 'Internal Server Error')

		assert_raises(StandardError) do
			PullPoolInfoJob.new.perform
		end
	end

	def test_perform_uses_fallback_values
		stub_request(:get, "http://#{@pool.host}:#{@pool.port}/api/info")
			.to_return(status: 200, body: { highScores: [] }.to_json)

		stub_request(:get, "http://#{@pool.host}:#{@pool.port}/api/network")
			.to_return(status: 200, body: {}.to_json)

		PullPoolInfoJob.new.perform

		@pool.reload
		assert_equal 0, @pool.best_difficulty.to_i
		assert_equal 0, @pool.network_difficulty.to_i
		assert_equal 0, @pool.network_hash.to_i
	end
end
