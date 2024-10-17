# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq/api'
require 'httparty'
require 'open-uri'
require 'logger'
require_relative 'base_worker'
require_relative 'download_pokemon_image_worker'
require_relative 'slideshow_image_generator_worker'
require_relative '../services/creator_pokemon_service'

# Sidekiq worker in charge of create pokemon data
class CreatorPokemonWorker < BaseWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5, queue: 'creator_pokemon'

  def initialize
    super
    @service = CreatorPokemonService.new
  end

  def perform(payload)
    behavior = payload['behavior'] || 'default'
    pokemon_names = payload['pokemon_names']

    custom_worker_behavior(behavior)

    pokemon_names.each do |pokemon_name|
      pokemon_name = pokemon_name.downcase
      next_payload = { 'pokemon_name' => pokemon_name, 'behavior' => behavior }

      return random_sleep if @service.create(pokemon_name).nil?

      DownloadPokemonImageWorker.perform_async(next_payload)
      SlideshowGeneratorWorker.perform_async(next_payload)
    end
  end

  def retry_in(attempt)
    case attempt
    when 1
      10
    when 2
      60
    when 3
      600
    else
      3600
    end
  end
end
