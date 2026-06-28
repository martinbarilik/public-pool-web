# frozen_string_literal: true

class RemoveWorkersCountFromUser < ActiveRecord::Migration[8.0]
	def change
		remove_column :users, :workers_count, :integer
	end
end
