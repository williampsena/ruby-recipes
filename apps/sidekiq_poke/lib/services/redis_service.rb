# frozen_string_literal: true

require 'redis'

# Responsible to fetch and put redis key / value
class RedisService
  def initialize
    @redis = Redis.new(url: ENV.fetch('REDIS_URL'))
  end

  def get(key)
    @redis.get(key)
  end

  def set(key, value)
    @redis.set(key, value)
  end

  def delete(key)
    @redis.del(key)
  end
end
