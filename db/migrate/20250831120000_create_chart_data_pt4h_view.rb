# frozen_string_literal: true

class CreateChartDataPt4hView < ActiveRecord::Migration[8.0]
	def up
		execute <<-SQL.squish
            CREATE OR REPLACE VIEW chart_data_pt4h_views AS
                WITH numbered_data AS (
                    SELECT
                    DATE_TRUNC('second', label) as label,
                    worker_id,
                    data::float,
                    ROW_NUMBER() OVER (
                        PARTITION BY worker_id
                        ORDER BY label
                    ) as row_num
                    FROM chart_datas
                    WHERE label >= NOW() - INTERVAL '4 hours'
                ), grouped_data AS (
                    SELECT
                    worker_id,
                    FLOOR((row_num - 1) / 4) as group_num,
                    MIN(label) as group_start_time,
                    AVG(data) as avg_data,
                    COUNT(*) as data_points
                    FROM numbered_data
                    GROUP BY worker_id, FLOOR((row_num - 1) / 4)
                )
                SELECT
                    group_start_time as interval_label,
                    worker_id,
                    avg_data,
                    data_points,
                    group_num
                FROM grouped_data
                ORDER BY interval_label, worker_id;
SQL
	end

	def down
		execute 'DROP VIEW IF EXISTS chart_data_pt4h_views;'
	end
end
