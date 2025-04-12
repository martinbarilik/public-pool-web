# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
	def up
		return if table_exists?(:users)

		create_table :users do |t|
			t.string :name
			t.numeric :best_difficulty, default: 0, null: false
			t.integer :workers_count, default: 0, null: false

			t.timestamps
		end
	end

	def down
		drop_table :users if table_exists?(:users)
	end
end
