# frozen_string_literal: true

require 'net/http'
require 'sidekiq-scheduler'

class PullHrJob
	include Sidekiq::Job

	POOL = Pool.first_or_create
	BASE_URI = "http://#{POOL.host}:#{POOL.port}/api/client/".freeze
	REQUEST_TIMEOUT = 10 # seconds
	# How often to record the same hash rate
	HASH_RATE_RECORD_INTERVAL = 10.minutes

	##
	# Fetch and update hash rate data for all users and their workers
	#
	# @example Response format
	# {
	#   "bestDifficulty": 6770941681.695331,
	#   "workersCount": 1,
	#   "workers": [
	#     {
	#       "sessionId": "9bd6c2f6",
	#       "name": "bitaxe",
	#       "bestDifficulty": "32356.88",
	#       "hashRate": 557362168183,
	#       "startTime": "2025-04-08T17:31:02.000Z",
	#       "lastSeen": "2025-04-08T17:36:28.000Z"
	#     }
	#   ]
	# }

	# @raise [StandardError] If API request fails or response is invalid
	def perform
		current_time = Time.zone.now

		User.includes(:workers).find_each do |user|
			json = fetch_user_data(user)
			process_user_data(user, json, current_time)
		rescue StandardError => e
			Rails.logger.error("Failed to process user #{user.id}: #{e.message}")
			Rails.logger.debug(e.backtrace.join("\n"))
			next
		end
	end

	private

	def fetch_user_data(user)
		uri = URI(construct_uri(user))
		response = Net::HTTP.start(uri.host, uri.port, read_timeout: REQUEST_TIMEOUT) do |http|
			http.get(uri.request_uri)
		end

		raise "API request failed with status #{response.code}" unless response.is_a?(Net::HTTPSuccess)

		JSON.parse(response.body, symbolize_names: true)
	rescue JSON::ParserError => e
		raise "Invalid JSON response: #{e.message}"
	end

	def process_user_data(user, json, current_time)
		workers, best_difficulty, workers_count = json.values_at(:workers, :bestDifficulty, :workersCount)
		user.update!(best_difficulty:, workers_count:)

		workers.each do |worker_hash|
			worker = user.workers.find_by(name: worker_hash[:name])

			next if worker.blank?

			update_worker(worker, worker_hash, current_time)
		end
	end

	def update_worker(worker, worker_hash, current_time)
		worker.update!(
			session_id: worker_hash[:sessionId],
			best_difficulty: worker_hash[:bestDifficulty],
			last_seen: worker_hash[:lastSeen],
			start_time: worker_hash[:startTime],
			hash_rate: worker_hash[:hashRate]
		)

		create_chart_data(worker, worker_hash[:hashRate], current_time)
	end

	def create_chart_data(worker, hash_rate, current_time)
		return if worker.chart_datas.exists?(
			label: (current_time - HASH_RATE_RECORD_INTERVAL)..current_time,
			data: hash_rate
		)

		worker.chart_datas.create!(label: current_time, data: hash_rate)
	end

	def construct_uri(user)
		[BASE_URI, user.name].join
	end
end
