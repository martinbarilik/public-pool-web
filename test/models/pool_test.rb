# frozen_string_literal: true

require 'test_helper'

class PoolTest < ActiveSupport::TestCase
	test 'eval_period converts period string to time' do
		pool = Pool.new(period: '1.days')
		assert_equal 1.day.ago.to_date, pool.eval_period.to_date

		pool.period = '7.days'
		assert_equal 7.days.ago.to_date, pool.eval_period.to_date

		pool.period = '1.months'
		assert_equal 1.month.ago.to_date, pool.eval_period.to_date
	end
end
