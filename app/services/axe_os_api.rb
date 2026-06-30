# frozen_string_literal: true

require 'net/http'
require 'json'

class AxeOsApi
	class Error < StandardError; end
	class RequestError < Error; end
	class JsonParseError < Error; end

	DEFAULT_TIMEOUT = 10

	def initialize(worker:, timeout: DEFAULT_TIMEOUT)
		@worker = worker
		@timeout = timeout
	end

	# GET /info - Get system information
	# {
	#   "power":21.9771729,
	#   "voltage":5070.3125,
	#   "current":14203.125,
	#   "temp":61.75,
	#   "temp2":-1,
	#   "vrTemp":69,
	#   "chain": "main"
	#   ...
	# }
	def info
		get('info')
	end

	private

	MAX_REDIRECTS = 5

	def get(path, limit: MAX_REDIRECTS)
		raise RequestError, 'Too many redirects' if limit <= 0

		uri = build_uri(path)
		http = Net::HTTP.new(uri.host, uri.port)
		http.open_timeout = @timeout
		http.read_timeout = @timeout

		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)

		case response
			when Net::HTTPSuccess
				JSON.parse(response.body, symbolize_names: true)
			when Net::HTTPRedirection
				location = response['location']
				raise RequestError, 'Redirect without location header' unless location

				get(location, limit: limit - 1)
			else
				raise RequestError, "HTTP #{response.code}: #{response.message}"
		end
	rescue JSON::ParserError => e
		raise JsonParseError, "Failed to parse JSON: #{e.message}"
	rescue SocketError, Net::OpenTimeout, Net::ReadTimeout => e
		raise RequestError, "Connection failed: #{e.message}"
	end

	def build_uri(path)
		return URI.parse(path) if path.start_with?('http')

		URI.parse("http://#{@worker.worker_ip}/api/system/#{path}")
	end
end
