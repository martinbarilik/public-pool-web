# frozen_string_literal: true

class HomeController < ApplicationController
	before_action :set_pool

	def index; end

	private

	def set_pool
		@pool = Pool.first_or_create
	end
end
