# frozen_string_literal: true

require 'sidekiq-scheduler'

class PullWorkerInfoJob
	include Sidekiq::Job

	# Fetch and update pool information from the API
	# @raise [StandardError] If API request fails or response is invalid
	def perform
		Worker.find_each do |worker|
			api = AxeOsApi.new(worker:)
			update_info(worker, api)
		rescue StandardError => e
			Rails.logger.error("Failed to update worker info: #{e.message}")
			Rails.logger.debug(e.backtrace.join("\n"))
			next
		end
	end

	private

	def update_info(worker, api)
		return if worker.worker_ip.blank?

		info = api.info

		worker.update!(
			temperature: info[:temp]
		)
	rescue AxeOsApi::RequestError, AxeOsApi::JsonParseError => e
		raise "Failed to fetch info: #{e.message}"
	end
end
