# frozen_string_literal: true

require 'sidekiq-scheduler'

class PullPoolInfoJob
	include Sidekiq::Job

	# Fetch and update pool information from the API
	# @raise [StandardError] If API request fails or response is invalid
	def perform
		api = PublicPoolApi.new
		pool = Pool.main

		update_info(pool, api)
		update_network_info(pool, api)
	rescue StandardError => e
		Rails.logger.error("Failed to update pool info: #{e.message}")
		Rails.logger.debug(e.backtrace.join("\n"))
		raise
	end

	private

	def update_info(pool, api)
		info = api.info

		pool.update!(
			best_difficulty: extract_best_difficulty(info)
		)
	rescue PublicPoolApi::RequestError, PublicPoolApi::JsonParseError => e
		raise "Failed to fetch info: #{e.message}"
	end

	def extract_best_difficulty(info)
		return 0 if info[:highScores].empty?

		info[:highScores].pluck(:bestDifficulty).max
	end

	def update_network_info(pool, api)
		network = api.network

		pool.update!(
			block_height: network[:blocks] || 0,
			network_difficulty: network[:difficulty] || 0,
			network_hash: network[:networkhashps] || 0
		)
	rescue PublicPoolApi::RequestError, PublicPoolApi::JsonParseError => e
		raise "Failed to fetch network info: #{e.message}"
	end
end
