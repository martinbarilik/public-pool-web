# frozen_string_literal: true

class ChartDataCleanupWorker
	include Sidekiq::Worker

	def perform
		# Delete chart data older than 7 days
		ChartData.where('created_at < ?', 7.days.ago).destroy_all
	end
end
