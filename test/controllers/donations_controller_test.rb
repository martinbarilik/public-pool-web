# frozen_string_literal: true

require 'test_helper'

class DonationsControllerTest < ActionDispatch::IntegrationTest
	test 'should get show' do
		get donate_url
		assert_response :success
	end

	test 'displays bitcoin address when configured' do
		ENV['DONATE_BTC_ADDRESS'] = 'bc1qtest123'
		get donate_url
		assert_match 'bc1qtest123', response.body
	ensure
		ENV.delete('DONATE_BTC_ADDRESS')
	end

	test 'displays lightning address when configured' do
		ENV['DONATE_LN_ADDRESS'] = 'user@getalby.com'
		get donate_url
		assert_match 'user@getalby.com', response.body
	ensure
		ENV.delete('DONATE_LN_ADDRESS')
	end

	test 'shows warning when no addresses configured' do
		ENV.delete('DONATE_BTC_ADDRESS')
		ENV.delete('DONATE_LN_ADDRESS')
		get donate_url
		assert_match 'not configured', response.body
	end
end
