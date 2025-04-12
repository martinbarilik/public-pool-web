# frozen_string_literal: true

class CreatePools < ActiveRecord::Migration[8.0]
	def change
		create_table :pools do |t|
			t.decimal :best_difficulty
			t.string :period, default: '1.hour', null: false
			t.integer :workers_count, default: 0, null: false
			t.string :host, null: false, default: 'umbrel.local'
			t.string :port, null: false, default: '2019'

			t.timestamps
		end
	end
end
