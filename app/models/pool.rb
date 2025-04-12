# frozen_string_literal: true

class Pool < ApplicationRecord
	def eval_period
		num, unit = period.split('.')
		num.to_i.send(unit).ago
	end
end
