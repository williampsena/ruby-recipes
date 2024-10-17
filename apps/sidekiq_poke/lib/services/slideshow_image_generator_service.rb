# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq/api'
require 'logger'
require 'rmagick'
require_relative '../services/download_pokemon_image_service'
require_relative '../workers/download_pokemon_image_worker'

# Pokemon slide show generator service
class SlideshowGeneratorService
  MAX_SLEEP = ENV.fetch('MAX_SLEEP', '1').to_i
  IMAGES_DIRECTORY = File.expand_path(ENV.fetch('IMAGES_PATH'))

  def initialize
    @redis = RedisService.new
  end

  def generate(pokemon_name)
    json_images = @redis.get("#{pokemon_name}::images")

    raise StandardError.new, "⛔ No pokemon images (#{pokemon_name}) fount at database" if json_images.nil?

    images = JSON.parse(json_images)

    logger.info("🎞️ generating slideshow with images : #{images.join(',')}")

    slideshow = Magick::ImageList.new
    slideshow.read(*images)
    slideshow.delay = 50

    target_path = File.join(IMAGES_DIRECTORY, "#{pokemon_name}.gif")
    slideshow.write(target_path)

    logger.info("🎞️ slideshow created: #{target_path}")

    target_path
  end

  private

  def logger
    @logger ||= Logger.new($stdout)
  end
end
