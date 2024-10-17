# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq/api'
require 'httparty'
require 'open-uri'
require 'logger'
require_relative '../workers/base_worker'
require_relative '../services/download_pokemon_image_service'

# Sidekiq worker in charge of downloading images
class DownloadPokemonImageWorker < BaseWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5, backoff: 10, queue: 'download_pokemon_image'

  def perform(payload)
    behavior = payload['behavior']
    pokemon_name = payload['pokemon_name']

    custom_worker_behavior(behavior)

    service = DownloadPokemonImageService.new
    service.download_image(pokemon_name)
  end
end
