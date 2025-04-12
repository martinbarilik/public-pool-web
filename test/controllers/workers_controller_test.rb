# frozen_string_literal: true

require 'test_helper'

class WorkersControllerTest < ActionDispatch::IntegrationTest
	fixtures :all

	setup do
		@worker = workers(:bitaxe)
	end

	test 'should get new' do
		get new_worker_url
		assert_response :success
	end

	test 'should create worker' do
		assert_difference('Worker.count') do
			post workers_url, params: { worker: { name: 'New Worker', user_id: users(:one).id } }
		end

		assert_redirected_to worker_url(Worker.last)
	end

	test 'should show worker' do
		get worker_url(@worker)
		assert_response :success
	end

	test 'should get edit' do
		get edit_worker_url(@worker)
		assert_response :success
	end

	test 'should update worker' do
		patch worker_url(@worker), params: { worker: { name: 'Updated Worker' } }
		assert_redirected_to worker_url(@worker)
	end

	test 'should destroy worker' do
		assert_difference('Worker.count', -1) do
			delete worker_url(@worker)
		end

		assert_redirected_to root_url
	end
end
