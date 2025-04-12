# frozen_string_literal: true

class ChartDatasController < ApplicationController
	before_action :set_pool

	def index
		update_pool_period if period_param.present?
		@data = fetch_chart_data
		render_chart_stream
	end

	private

	def set_pool
		@pool = Pool.first_or_create
	end

	def update_pool_period
		@pool.update!(period: sanitize_period(period_param))
	end

	def period_param
		params[:period]
	end

	def worker_id_param
		params[:worker_id]
	end

	def sanitize_period(period)
		period.to_s.gsub('.ago', '').presence
	end

	def fetch_chart_data
		ChartData.chart_data(
			since: @pool.eval_period,
			worker_id: worker_id_param
		)
	end

	def render_chart_stream
		render turbo_stream: turbo_stream.replace(
			chart_dom_id,
			template: 'chart_datas/index',
			locals: { worker_id: worker_id_param }
		)
	end

	def chart_dom_id
		if worker_id_param.present?
			"chart_datas_worker_#{worker_id_param}"
		else
			'chart_datas'
		end
	end
end
