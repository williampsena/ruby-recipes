# frozen_string_literal: true

require 'httparty'
require 'open-uri'
require 'logger'
require_relative 'redis_service'

# Service responsible to create pokemon data at database
class CreatorPokemonService
  BASE_API_URL = ENV.fetch('BASE_API_URL')

  def initialize
    @redis = RedisService.new
  end

  def logger
    @logger ||= Logger.new($stdout)
  end

  def create(pokemon_name)
    if already_exists?(pokemon_name)
      logger.warn('🙄 Pokemon already persisted at Redis')
      return
    end

    response = HTTParty.get("#{BASE_API_URL}/pokemon/#{pokemon_name}")

    raise StandardError.new, "⛔ Failed to find Pokémon: #{pokemon_name}" unless response.success?

    data = response.parsed_response
    @redis.set(pokemon_name, data.to_json)

    logger.info('💾 Pokemon data persisted at Redis')

    data
  end

  private

  def already_exists?(pokemon_name)
    @redis.get(pokemon_name) != nil
  end
end
