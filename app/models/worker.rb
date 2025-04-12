# frozen_string_literal: true

class Worker < ApplicationRecord
	belongs_to :user, optional: false

	has_many :chart_datas, dependent: :destroy

	after_update_commit lambda {
		broadcast_replace_to self, partial: 'workers/worker', locals: { worker: self }
	}

	validates :name, presence: true
end
