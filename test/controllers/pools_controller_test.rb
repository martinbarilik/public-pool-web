# frozen_string_literal: true

require 'test_helper'

class PoolsControllerTest < ActionDispatch::IntegrationTest
	setup do
		@pool = pools(:one)
	end

	test 'should update pool' do
		patch pool_url(@pool), params: { pool: { host: 'umbrel.local2' } }
		assert_redirected_to root_url
	end
end
