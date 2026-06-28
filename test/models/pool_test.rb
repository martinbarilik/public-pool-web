# frozen_string_literal: true

require 'test_helper'

class PoolTest < ActiveSupport::TestCase
	fixtures :pools

	test 'eval_period converts period string to time' do
		pool = Pool.new(period: '1.days')
		assert_equal 1.day.ago.to_date, pool.eval_period.to_date

		pool.period = '7.days'
		assert_equal 7.days.ago.to_date, pool.eval_period.to_date

		pool.period = '1.months'
		assert_equal 1.month.ago.to_date, pool.eval_period.to_date
	end

	test 'validates presence of host' do
		pool = Pool.new(host: nil, port: '2019')
		assert_not pool.valid?
		assert_includes pool.errors[:host], "can't be blank"
	end

	test 'validates presence of port' do
		pool = Pool.new(host: '127.0.0.1', port: nil)
		assert_not pool.valid?
		assert_includes pool.errors[:port], "can't be blank"
	end

	test 'main returns existing pool' do
		existing = pools(:one)
		result = Pool.main
		assert_equal existing.id, result.id
	end

	test 'main creates pool with defaults when none exists' do
		Pool.delete_all
		pool = Pool.main
		assert pool.persisted?
		assert_equal Pool::DEFAULT_HOST, pool.host
		assert_equal Pool::DEFAULT_PORT.to_s, pool.port.to_s
	end
end
