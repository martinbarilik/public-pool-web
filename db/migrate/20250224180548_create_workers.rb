# frozen_string_literal: true

class CreateWorkers < ActiveRecord::Migration[8.0]
	def change
		create_table :workers do |t|
			t.string :name
			t.belongs_to :user, null: false, foreign_key: true
			t.string :session_id
			t.numeric :best_difficulty
			t.numeric :hash_rate
			t.datetime :start_time
			t.datetime :last_seen

			t.timestamps
		end
	end
end
