# frozen_string_literal: true

require './app'

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') }
end

use Rack::Session::Cookie, secret: ENV.fetch('COOKIE_SECRET')
run Rack::URLMap.new('/' => PokeApp, '/sidekiq' => Sidekiq::Web)
