# frozen_string_literal: true

require 'httparty'
require 'open-uri'
require 'logger'
require 'redis'
require 'uri'
require 'base64'
require_relative 'redis_service'

# Service responsible to download pokemon image
class DownloadPokemonImageService
  BASE_API_URL = ENV.fetch('BASE_API_URL')
  IMAGES_DIRECTORY = File.expand_path(ENV.fetch('IMAGES_PATH'))

  def initialize
    @redis = RedisService.new
  end

  def logger
    @logger ||= Logger.new($stdout)
  end

  def valid_url?(str)
    uri = URI.parse(str)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    false
  end

  def download_image(pokemon_name)
    json_payload = @redis.get(pokemon_name)

    raise StandardError.new, "⛔ No pokemon (#{pokemon_name}) fount at database" if json_payload.nil?

    payload = JSON.parse(json_payload)

    images = payload['sprites'].map do |ref, image_url|
      if image_url.nil? || !valid_url?(image_url)
        logger.warn("❌ The image url is invalid #{image_url || ''}")
        next
      end

      image_path = save_image(pokemon_name, ref, image_url)
      logger.info("🐦‍🔥 Downloaded image for #{pokemon_name}")

      image_path
    end.compact

    raise StandardError.new, "⛔ No image found for #{pokemon_name}" if images.empty?

    @redis.set("#{pokemon_name}::images", images.to_json)

    images
  end

  private

  def save_image(pokemon_name, ref, image_url)
    FileUtils.mkdir_p(IMAGES_DIRECTORY)
    image_path = File.join(IMAGES_DIRECTORY, "#{pokemon_name}_#{ref}.png")

    unless File.exist?(image_path)
      logger.info("🖼️ Downloading image #{image_url}")
      image_response = HTTParty.get(image_url)

      raise StandardError.new, "⛔ Failed to download image for #{pokemon_name}" unless image_response.success?

      File.binwrite(image_path, image_response.body)

      logger.info("🖼️ Image saved to #{image_path}")
    end

    persist_at_database(pokemon_name, ref, image_path)
    persist_dummy_key(pokemon_name, ref)

    image_path
  end

  def persist_at_database(pokemon_name, ref, image_path)
    data_bytes = File.binread(image_path)

    @redis.set("#{pokemon_name}::#{ref}", Base64.encode64(data_bytes))
  end

  def persist_dummy_key(pokemon_name, ref)
    size_in_mb = 1
    size_in_bytes = size_in_mb * 1024 * 1024
    value = 'A' * size_in_bytes
    @redis.set("#{pokemon_name}::#{ref}::dummy", value)
  end
end
