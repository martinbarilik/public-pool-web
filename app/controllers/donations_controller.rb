# frozen_string_literal: true

class DonationsController < ApplicationController
	def show
		@btc_address = ENV.fetch('DONATE_BTC_ADDRESS', nil)
		@ln_address = ENV.fetch('DONATE_LN_ADDRESS', nil)
	end
end
