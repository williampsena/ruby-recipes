# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq/api'
require 'logger'
require 'rmagick'
require_relative '../services/slideshow_image_generator_service'
require_relative '../workers/base_worker'
require_relative '../workers/download_pokemon_image_worker'

# Sidekiq slow worker in charge of downloading images
class SlideshowGeneratorWorker < BaseWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5, backoff: 20, queue: 'slideshow_generator'

  def perform(payload)
    behavior = payload['behavior']
    pokemon_name = payload['pokemon_name']

    custom_worker_behavior(behavior)

    service = SlideshowGeneratorService.new
    service.generate(pokemon_name)
  end
end
