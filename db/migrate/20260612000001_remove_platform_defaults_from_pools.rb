# frozen_string_literal: true

class RemovePlatformDefaultsFromPools < ActiveRecord::Migration[8.0]
	def change
		change_table :pools, bulk: true do |t|
			t.change_default :host, from: '127.0.0.1', to: nil
			t.change_default :port, from: '2019', to: nil
		end
	end
end
