# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq/api'
require 'dotenv/load'
require 'redis'
require_relative 'lib/workers/creator_pokemon_worker'
require_relative 'lib/workers/download_pokemon_image_worker'
require_relative 'lib/workers/slideshow_image_generator_worker'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') }
end
