# frozen_string_literal: true

class CreateChartDatas < ActiveRecord::Migration[8.0]
	def change
		create_table :chart_datas do |t|
			t.belongs_to :worker, null: false, foreign_key: true
			t.datetime :label
			t.numeric :data

			t.timestamps
		end
	end
end
