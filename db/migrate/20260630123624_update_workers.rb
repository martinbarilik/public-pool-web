# frozen_string_literal: true

class UpdateWorkers < ActiveRecord::Migration[8.1]
	def up
		add_column :workers, :temperature, :float
		add_column :workers, :worker_ip, :string
	end

	def down
		remove_column :workers, :temperature
		remove_column :workers, :worker_ip
	end
end
