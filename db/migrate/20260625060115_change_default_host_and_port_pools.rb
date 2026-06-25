# frozen_string_literal: true

class ChangeDefaultHostAndPortPools < ActiveRecord::Migration[8.0]
	def up
		change_column_default :pools, :host, '127.0.0.1'
	end

	def down
		change_column_default :pools, :host, 'umbrel.local'
	end
end
