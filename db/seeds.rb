# frozen_string_literal: true

# testing data for umbrel / github preview picture
# user = User.create(name: "bc1#{SecureRandom.hex(19)}")
# supra = user.workers.create!(name: 'bitaxe')
# gamma = user.workers.create!(name: 'bitaxeGAMMA')
# SUPRA_INTERVAL = 420_000_000_000.0..1_020_000_000_000.0
# GAMMA_INTERVAL = 700_000_000_000.0..1_900_000_000_000.0

# # start_time = 2.hours.ago
# start_time = 7.days.ago
# loop do
# 	break if start_time > Time.current

# 	Worker.find_each do |worker|
# 		worker.update!(last_seen: start_time)
# 		ChartData.create!(worker:, label: start_time, data: rand(worker.name == 'bitaxe' ? SUPRA_INTERVAL : GAMMA_INTERVAL))
# 	end

# 	start_time += 1.minute
# end
