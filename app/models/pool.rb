# frozen_string_literal: true

class Pool < ApplicationRecord
	include ActionView::RecordIdentifier

	DEFAULT_HOST = ENV.fetch('PUBLIC_POOL_HOST', '127.0.0.1')
	DEFAULT_PORT = ENV.fetch('PUBLIC_POOL_PORT', '2019')

	validates :host, :port, presence: true

	after_save_commit :broadcast_update

	def self.main
		first_or_create(host: DEFAULT_HOST, port: DEFAULT_PORT)
	end

	def eval_period
		num, unit = period.split('.')
		num.to_i.send(unit).ago
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
