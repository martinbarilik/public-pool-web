# frozen_string_literal: true

require 'test_helper'

class WorkerTest < ActiveSupport::TestCase
	include ActionCable::TestHelper

	setup do
		@user = users(:one)
		@worker = Worker.create!(
			name: 'Test Worker',
			user: @user
		)
	end

	test 'belongs to user' do
		assert_respond_to @worker, :user
		assert_instance_of User, @worker.user
	end

	test 'has many chart_datas' do
		assert_respond_to @worker, :chart_datas
		assert_kind_of ActiveRecord::Associations::CollectionProxy, @worker.chart_datas
	end

	test 'requires name' do
		worker = Worker.new(user: @user)
		assert_not worker.valid?
		assert_includes worker.errors[:name], "can't be blank"
	end

	test 'requires user' do
		worker = Worker.new(name: 'Test Worker')
		assert_not worker.valid?
		assert_includes worker.errors[:user], 'must exist'
	end

	test 'destroys associated chart_datas' do
		# Create some chart data
		chart_data = ChartData.create!(
			worker: @worker,
			label: Time.current,
			data: 42.0
		)

		assert_difference 'ChartData.count', -1 do
			@worker.destroy
		end

		assert_raises(ActiveRecord::RecordNotFound) do
			chart_data.reload
		end
	end
end
