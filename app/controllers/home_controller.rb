# frozen_string_literal: true

class HomeController < ApplicationController
	before_action :set_pool

	def index; end

	private

	def set_pool
		@pool = Pool.main
	end
end
