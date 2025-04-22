# frozen_string_literal: true

class ChartDatasController < ApplicationController
	before_action :set_pool, only: :index
	before_action :update_pool_period, only: :index

	def index
		@data = fetch_chart_data
		@average = @data&.size&.positive? ? (@data.sum(&:last) / @data.size) : 0
		@min_max =
			if @data&.size&.positive?
				{
					max: @data.max_by(&:last).last,
					min: @data.min_by(&:last).last
				}
			else
				{ max: 1000, min: 0 }
			end

		render_chart_stream
	end

	private

	def set_pool
		@pool = Pool.first_or_create
	end

	def update_pool_period
		return if period_param.blank?

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
