# frozen_string_literal: true

class RemoveWorkersCountFromPool < ActiveRecord::Migration[8.0]
	def change
		remove_column :pools, :workers_count, :integer
	end
end
