# frozen_string_literal: true

require 'ipaddr'

class Worker < ApplicationRecord
	belongs_to :user, optional: false

	has_many :chart_datas, dependent: :destroy

	after_update_commit lambda {
		broadcast_replace_to self, partial: 'workers/worker', locals: { worker: self }
	}

	validates :name, presence: true
	validate :worker_ip_must_be_valid_ip

	private

	def worker_ip_must_be_valid_ip
		return if worker_ip.blank?

		IPAddr.new(worker_ip)
	rescue IPAddr::InvalidAddressError
		errors.add(:worker_ip, :invalid)
	end
end
