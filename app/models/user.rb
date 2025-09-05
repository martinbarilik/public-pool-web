# frozen_string_literal: true

class User < ApplicationRecord
	has_many :workers, dependent: :destroy

	normalizes :name, with: -> { it.tr(' ', '') }

	validates :name, presence: true
end
