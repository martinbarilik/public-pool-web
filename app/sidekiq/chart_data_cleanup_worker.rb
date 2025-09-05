# frozen_string_literal: true

class ChartDataCleanupWorker
	include Sidekiq::Worker

	def perform
		# Delete chart data older than 7 days
		ChartData
			.where(created_at: ...7.days.ago)
			.destroy_all

		# Delete chart data without pairs breaking chart
		ChartData
			.where(id: unicorn_ids)
			.destroy_all

		# Delete chart data with duplicate labels breaking chart
		ChartData
			.where(id: duplicate_ids)
			.destroy_all
	end

	def unicorns
		ChartData
			.select(:label)
			.group(:label)
			.having('COUNT(*) = 1')
	end

	def duplicates
		ChartData
			.select(:label)
			.group(:label, :worker_id)
			.having('COUNT(*) > 1')
	end

	def unicorn_ids
		ChartData
			.select(:id)
			.where(label: unicorns)
	end

	def duplicate_ids
		ChartData.find_by_sql(<<-SQL.squish)
			SELECT id FROM (
				SELECT id, ROW_NUMBER() OVER (PARTITION BY label, worker_id ORDER BY id) as rn
				FROM chart_datas
				WHERE label IN (#{duplicates.to_sql})
			) ranked_data
			WHERE rn > 1
		SQL
	end
end
