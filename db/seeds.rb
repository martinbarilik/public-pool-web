# frozen_string_literal: true

# testing data for umbrel / github preview picture
# user = User.create(name: "bc1#{SecureRandom.hex(19)}")
# worker = user.workers.create!(name: 'bitaxe')

# start_time = 2.hours.ago
start_time = 7.days.ago
loop do
	break if start_time > Time.current

	Worker.where(id: [14]).find_each do |worker|
		worker.update!(last_seen: start_time)
		ChartData.create!(worker:, label: start_time, data: rand(530_000_000_000.0..1_000_000_000_000.0))
	end

	start_time += 1.minute
end
