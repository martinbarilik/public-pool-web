# frozen_string_literal: true

class WorkersController < ApplicationController
	before_action :set_worker, only: %i[show edit update destroy]

	# GET /workers or /workers.json
	def index
		@workers = Worker.all
	end

	# GET /workers/1 or /workers/1.json
	def show; end

	# GET /workers/new
	def new
		@worker = Worker.new
	end

	# GET /workers/1/edit
	def edit; end

	# POST /workers or /workers.json
	def create
		@worker = Worker.new(worker_params)

		respond_to do |format|
			if @worker.save
				format.html { redirect_to @worker, notice: 'Worker was successfully created.' }
				format.json { render :show, status: :created, location: @worker }
			else
				format.html { render :new, status: :unprocessable_entity }
				format.json { render json: @worker.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /workers/1 or /workers/1.json
	def update
		respond_to do |format|
			if @worker.update(worker_params)
				format.html { redirect_to @worker, notice: 'Worker was successfully updated.' }
				format.json { render :show, status: :ok, location: @worker }
			else
				format.html { render :edit, status: :unprocessable_entity }
				format.json { render json: @worker.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /workers/1 or /workers/1.json
	def destroy
		@worker.destroy!

		respond_to do |format|
			format.html { redirect_to root_path, status: :see_other, notice: 'Worker was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private

	# Use callbacks to share common setup or constraints between actions.
	def set_worker
		@worker = Worker.find(params.expect(:id))
	end

	# Only allow a list of trusted parameters through.
	def worker_params
		params.expect(worker: %i[name user_id])
	end
end
