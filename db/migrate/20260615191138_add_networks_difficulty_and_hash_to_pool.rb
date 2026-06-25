# frozen_string_literal: true

class AddNetworksDifficultyAndHashToPool < ActiveRecord::Migration[8.0]
	def change
		change_table :pools, bulk: true do |t|
			t.numeric :network_difficulty, default: 0, null: false
			t.numeric :network_hash, default: 0, null: false
			t.numeric :block_height, default: 0, null: false
		end
	end
end
