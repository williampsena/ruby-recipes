# frozen_string_literal: true

require 'dotenv/load'
require 'sinatra'
require 'sidekiq/web'
require_relative 'lib/workers/creator_pokemon_worker'
require_relative 'sidekiq'

module RedisClients
  REDIS = ConnectionPool.new(size: 5, timeout: 5) { Redis.new(url: ENV.fetch('REDIS_URL')) }
  REDIS_PERSISTENT = ConnectionPool.new(size: 5, timeout: 5) { Redis.new(url: ENV.fetch('REDIS_PERSISTENT_URL')) }
end

def redis_target(target)
  target == 'high' ? RedisClients::REDIS_PERSISTENT : RedisClients::REDIS
end

# Sinatra application
class PokeApp < Sinatra::Base
  set :server_settings, timeout: 10
  set :public_folder, File.expand_path(ENV.fetch('IMAGES_PATH'))

  enable :logging

  get '/' do
    '👾 Welcome to the Pokémon image downloader!'
  end

  post '/pokemon/batch' do
    data = JSON.parse(request.body.read)
    pokemon_names = data['names'].map(&:downcase)
    redis = redis_target(data['priority'] || '')

    Sidekiq::Client.via(redis) do
      CreatorPokemonWorker.perform_async({ 'behaviour' => data['behaviour'], 'pokemon_names' => pokemon_names })
    end

    "Started downloading image for #{pokemon_names.join(',')}"
  end

  post '/pokemon/:name' do
    pokemon_name = params['name']
    redis = redis_target(params['priority'] || '')

    Sidekiq::Client.via(redis) do
      CreatorPokemonWorker.perform_async([pokemon_name])
    end

    "Started downloading image for #{pokemon_name}"
  end

  run! if app_file == $PROGRAM_NAME
end
