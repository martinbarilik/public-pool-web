# frozen_string_literal: true

class Pool < ApplicationRecord
	include ActionView::RecordIdentifier

	DEFAULT_HOST = ENV.fetch('PUBLIC_POOL_HOST', '127.0.0.1')
	DEFAULT_PORT = ENV.fetch('PUBLIC_POOL_PORT', '2019')
	ALLOWED_PERIOD_UNITS = %w[minute minutes hour hours day days week weeks month months year years].freeze
	PERIOD_FORMAT = /\A\d+\.(#{ALLOWED_PERIOD_UNITS.join('|')})\z/

	validates :host, :port, presence: true
	validates :port, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 65_535 }

	validates :period, format: { with: PERIOD_FORMAT }

	def self.valid_period?(value)
		value.to_s.match?(PERIOD_FORMAT)
	end

	after_save_commit :broadcast_update

	def self.main
		first_or_create(host: DEFAULT_HOST, port: DEFAULT_PORT)
	end

	def eval_period
		num, unit = period.split('.')

		duration =
			case unit
				when 'minute', 'minutes' then num.to_i.minutes
				when 'hour', 'hours' then num.to_i.hours
				when 'day', 'days' then num.to_i.days
				when 'week', 'weeks' then num.to_i.weeks
				when 'month', 'months' then num.to_i.months
				when 'year', 'years' then num.to_i.years
				else raise ArgumentError, "Invalid period: #{period.inspect}"
			end

		duration.ago
	end

	private

	def broadcast_update
		broadcast_replace_to(
			dom_id(self),
			target: dom_id(self),
			partial: 'pools/info',
			locals: {
				pool: self
			}
		)
	end
end
