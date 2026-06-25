# frozen_string_literal: true

require 'net/http'
require 'json'

class PublicPoolApi
	class Error < StandardError; end
	class RequestError < Error; end
	class JsonParseError < Error; end

	DEFAULT_TIMEOUT = 10

	def initialize(timeout: DEFAULT_TIMEOUT)
		@pool = Pool.main
		@timeout = timeout
	end

	# GET /info - Site info (blocks, user agents, high scores, uptime)
	# {blockData: [],
	#  userAgents: [{userAgent: "bitaxe", count: 1, bestDifficulty: 25215782.653462656, totalHashRate: 785180231734.1897}],
	#  highScores:
	#   [{updatedAt: "2026-01-04 03:21:00", bestDifficulty: 8390628145.027727, bestDifficultyUserAgent: "bitaxe"},
	#    {updatedAt: "2026-02-24 04:05:56", bestDifficulty: 3126317155.2819834, bestDifficultyUserAgent: "bitaxe"}],
	#  uptime: "2026-06-14T13:43:19.504Z"}
	def info
		get('info')
	end

	# GET /pool - Pool stats (hashrate, block height, miners, blocks found)
	# {totalHashRate: 823779417445.0692, blockHeight: 954132, totalMiners: 1, blocksFound: [], fee: 0}
	def pool_stats
		get('pool')
	end

	# GET /network - Bitcoin network mining info
	# {blocks: 954132,
	#  currentblockweight: 3999946,
	#  currentblocktx: 3222,
	#  bits: "170240c3",
	#  difficulty: 124932866006548.2,
	#  target: "0000000000000000000240c30000000000000000000000000000000000000000",
	#  networkhashps: 842834778008192700000,
	#  pooledtx: 5034,
	#  chain: "main",
	#  next: {height: 954133, bits: "170240c3", difficulty: 124932866006548.2, target: "0000000000000000000240c30000000000000000000000000000000000000000"},
	#  warnings: []}
	def network
		get('network')
	end

	# GET /info/chart - Site hashrate graph data
	# [{label: "2026-06-16T19:40:00.000Z", data: 689027286740},
	#  {label: "2026-06-16T19:50:00.000Z", data: 674367131703},
	#  ...
	def info_chart
		get('info/chart')
	end

	# GET /client/:address - Client info with workers for an address
	# {bestDifficulty: 3126317155.2819834,
	#  workersCount: 1,
	#  workers: [{sessionId: "7825cd40", name: "bitaxe", bestDifficulty: "25215782.65", hashRate: 807816522071, startTime: "2026-06-14T13:44:34.000Z", lastSeen: "2026-06-17T19:37:48.000Z"}]}
	def client(address)
		get("client/#{address}")
	end

	# GET /client/:address/chart - Chart data for an address
	# [{label: "2026-06-16T19:40:00.000Z", data: 689027286739.6267},
	#  {label: "2026-06-16T19:50:00.000Z", data: 674367131702.6133},
	#  ...
	def client_chart(address)
		get("client/#{address}/chart")
	end

	# GET /client/:address/:worker_name - Worker group info
	# [{label: "2026-06-16T19:40:00.000Z", data: 689027286739.6267},
	#  {label: "2026-06-16T19:50:00.000Z", data: 674367131702.6133},
	#  ...
	def worker_group(address, worker_name)
		get("client/#{address}/#{worker_name}")
	end

	# GET /client/:address/:worker_name/:session_id - Specific worker info
	# {sessionId: "7825cd40",
	#  name: "bitaxe",
	#  bestDifficulty: 25215782,
	#  chartData:
	#  [{label: "2026-06-16T19:50:00.000Z", data: 674367131702.6133},
	#  {label: "2026-06-16T20:00:00.000Z", data: 659706976665.6},
	#  ...
	def worker(address, worker_name, session_id)
		get("client/#{address}/#{worker_name}/#{session_id}")
	end

	# GET /share/top-difficulties - Top difficulty submissions
	def top_difficulties
		get('share/top-difficulties')
	end

	# Fetch all GET endpoints at once
	def fetch_all(address: nil, worker_name: nil, session_id: nil)
		result = {
			info:,
			pool_stats:,
			network:,
			info_chart:,
			top_difficulties:
		}

		if address
			result[:client] = client(address)
			result[:client_chart] = client_chart(address)

			if worker_name
				result[:worker_group] = worker_group(address, worker_name)
				result[:worker] = worker(address, worker_name, session_id) if session_id
			end
		end

		result
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

		URI.parse("http://#{@pool.host}:#{@pool.port}/api/#{path}")
	end
end
