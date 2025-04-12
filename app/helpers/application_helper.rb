# frozen_string_literal: true

module ApplicationHelper
	# Unit prefixes for hash rate and difficulty
	UNIT_PREFIXES = {
		1e18 => 'E',
		1e15 => 'P',
		1e12 => 'T',
		1e9 => 'G',
		1e6 => 'M',
		1e3 => 'k',
		1 => ''
	}.freeze

	# Formats a hash rate value with appropriate SI unit prefix
	# @param hash_rate [Numeric, nil] The hash rate value to format
	# @return [String] Formatted hash rate with units
	def humanize_hash_rate(hash_rate)
		format_with_prefix(hash_rate, unit_suffix: 'H/s')
	end

	# Formats a difficulty value with appropriate SI unit prefix
	# @param difficulty [Numeric, nil] The difficulty value to format
	# @return [String] Formatted difficulty with units
	def humanize_difficulty(difficulty)
		format_with_prefix(difficulty, unit_suffix: '')
	end

	private

	# Common formatting logic for numeric values with SI prefixes
	# @param value [Numeric, nil] The value to format
	# @param unit_suffix [String] The unit suffix to append
	# @return [String] Formatted value with appropriate prefix and unit
	def format_with_prefix(value, unit_suffix:)
		return 'N/A' if value.nil?

		UNIT_PREFIXES.each do |threshold, prefix|
			if value >= threshold || threshold == 1
				formatted_value = (value / threshold).round(2)
				return "#{formatted_value} #{prefix}#{unit_suffix}".strip
			end
		end
	end
end
