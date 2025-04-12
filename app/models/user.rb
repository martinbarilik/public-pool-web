# frozen_string_literal: true

class User < ApplicationRecord
	has_many :workers, dependent: :destroy

	normalizes :name, with: -> { _1.tr(' ', '').downcase }

	validates :name, presence: true
end
