# frozen_string_literal: true

class PoolsController < ApplicationController
	before_action :set_pool, only: %i[update]

	# PATCH/PUT /pools/1 or /pools/1.json
	def update
		respond_to do |format|
			if @pool.update(pool_params)
				format.html do
					redirect_to root_path, notice: 'Pool settings were successfully updated. Restart the app to apply changes.'
				end
				format.json { render :show, status: :ok, location: @pool }
			else
				format.html { render :edit, status: :unprocessable_entity }
				format.json { render json: @pool.errors, status: :unprocessable_entity }
			end
		end
	end

	private

	def set_pool
		@pool = Pool.first_or_create
	end

	def pool_params
		params.expect(pool: [:host])
	end
end
