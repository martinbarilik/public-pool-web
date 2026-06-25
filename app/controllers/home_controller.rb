# frozen_string_literal: true

class HomeController < ApplicationController
	before_action :set_pool
	after_action :refresh_pool_info, only: [:index]

	def index; end

	private

	def refresh_pool_info
		PullPoolInfoJob.perform_in(1.second)
	end

	def set_pool
		@pool = Pool.main
	end
end
