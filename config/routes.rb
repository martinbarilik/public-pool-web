# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
	resources :users
	resources :workers, except: [:index]

	resources :chart_datas, only: %i[index] do
		collection do
			delete :cleanup
		end
	end

	resources :pools, only: [:update]

	get 'donate', to: 'donations#show'

	# Restrict the Sidekiq dashboard to an IP allowlist (comma-separated, defaults to localhost).
	sidekiq_allowed_ips = ENV.fetch('SIDEKIQ_WEB_ALLOWED_IPS', '127.0.0.1,::1').split(',').map(&:strip)
	mount Sidekiq::Web => '/sidekiq', constraints: ->(request) { sidekiq_allowed_ips.include?(request.remote_ip) }

	# Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
	# Can be used by load balancers and uptime monitors to verify that the app is live.
	get 'up' => 'rails/health#show', as: :rails_health_check

	# Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
	# get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
	# get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

	# Defines the root path route ("/")
	root 'home#index'
end
