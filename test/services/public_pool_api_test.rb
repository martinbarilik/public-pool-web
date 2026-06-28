# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'

class PublicPoolApiTest < ActiveSupport::TestCase
	fixtures :pools

	setup do
		@pool = pools(:one)
		@api = PublicPoolApi.new
		@base_url = "http://#{@pool.host}:#{@pool.port}/api"
	end

	# --- info ---

	test 'info returns parsed JSON response' do
		stub_request(:get, "#{@base_url}/info")
			.to_return(status: 200, body: {
				highScores: [{ bestDifficulty: 123.45 }],
				uptime: '2026-06-14T13:43:19.504Z'
			}.to_json)

		result = @api.info
		assert_equal 123.45, result[:highScores].first[:bestDifficulty]
		assert_equal '2026-06-14T13:43:19.504Z', result[:uptime]
	end

	# --- pool_stats ---

	test 'pool_stats returns parsed JSON response' do
		stub_request(:get, "#{@base_url}/pool")
			.to_return(status: 200, body: {
				totalHashRate: 823_779_417_445,
				totalMiners: 1,
				fee: 0
			}.to_json)

		result = @api.pool_stats
		assert_equal 823_779_417_445, result[:totalHashRate]
		assert_equal 1, result[:totalMiners]
	end

	# --- network ---

	test 'network returns parsed JSON response' do
		stub_request(:get, "#{@base_url}/network")
			.to_return(status: 200, body: {
				blocks: 954_132,
				difficulty: 124_932_866_006_548,
				networkhashps: 842_834_778_008_192_700_000
			}.to_json)

		result = @api.network
		assert_equal 954_132, result[:blocks]
		assert_equal 124_932_866_006_548, result[:difficulty]
	end

	# --- client ---

	test 'client returns parsed JSON for address' do
		stub_request(:get, "#{@base_url}/client/testuser")
			.to_return(status: 200, body: {
				bestDifficulty: 100.0,
				workersCount: 2,
				workers: []
			}.to_json)

		result = @api.client('testuser')
		assert_equal 100.0, result[:bestDifficulty]
		assert_equal 2, result[:workersCount]
	end

	# --- error handling ---

	test 'raises RequestError on HTTP error' do
		stub_request(:get, "#{@base_url}/info")
			.to_return(status: 500, body: 'Internal Server Error')

		assert_raises(PublicPoolApi::RequestError) do
			@api.info
		end
	end

	test 'raises RequestError on timeout' do
		stub_request(:get, "#{@base_url}/info").to_timeout

		assert_raises(PublicPoolApi::RequestError) do
			@api.info
		end
	end

	test 'raises RequestError on socket error' do
		stub_request(:get, "#{@base_url}/info").to_raise(SocketError.new('Connection refused'))

		assert_raises(PublicPoolApi::RequestError) do
			@api.info
		end
	end

	test 'raises JsonParseError on invalid JSON' do
		stub_request(:get, "#{@base_url}/info")
			.to_return(status: 200, body: 'not json')

		assert_raises(PublicPoolApi::JsonParseError) do
			@api.info
		end
	end

	# --- redirects ---

	test 'follows redirects' do
		stub_request(:get, "#{@base_url}/info")
			.to_return(status: 302, headers: { 'Location' => "#{@base_url}/info2" })

		stub_request(:get, "#{@base_url}/info2")
			.to_return(status: 200, body: { data: 'ok' }.to_json)

		result = @api.info
		assert_equal 'ok', result[:data]
	end

	test 'raises RequestError on too many redirects' do
		stub_request(:get, "#{@base_url}/info")
			.to_return(status: 302, headers: { 'Location' => "#{@base_url}/info" })

		assert_raises(PublicPoolApi::RequestError) do
			@api.info
		end
	end

	test 'raises RequestError on redirect without location' do
		stub_request(:get, "#{@base_url}/info")
			.to_return(status: 302, headers: {})

		assert_raises(PublicPoolApi::RequestError) do
			@api.info
		end
	end
end
