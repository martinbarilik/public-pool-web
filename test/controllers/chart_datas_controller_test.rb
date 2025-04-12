# frozen_string_literal: true

require 'test_helper'

class ChartDatasControllerTest < ActionDispatch::IntegrationTest
	test 'should get index' do
		get chart_datas_url
		assert_response :success
		assert_match(/<turbo-stream/, @response.body)
	end
end
