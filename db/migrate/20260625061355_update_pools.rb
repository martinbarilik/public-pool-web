# frozen_string_literal: true

class UpdatePools < ActiveRecord::Migration[8.0]
	def change
		pool = Pool.main

		if (host = ENV.fetch('PUBLIC_POOL_HOST', nil)).present?
			pool.update!(host:)
		end

		if (port = ENV.fetch('PUBLIC_POOL_PORT', nil)).present?
			pool.update!(port:)
		end
	end
end
