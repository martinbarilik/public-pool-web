# frozen_string_literal: true

class RemovePlatformDefaultsFromPools < ActiveRecord::Migration[8.0]
	def change
		change_column_default :pools, :host, from: '127.0.0.1', to: nil
		change_column_default :pools, :port, from: '2019', to: nil
	end
end
