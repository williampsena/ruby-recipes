# frozen_string_literal: true

# Base worker with custom features
class BaseWorker
  # Random number class to enable mock testing
  class Random
    def number(max = 10)
      rand(1..max)
    end
  end

  def random
    @random ||= Random.new
  end

  def random_error
    return unless random.number.even?

    raise_error
  end

  def raise_error
    raise 'Sorry consumer is busy 🥴.'
  end

  def random_sleep
    random_time = random.number
    sleep(random_time)
  end

  def custom_worker_behavior(type)
    case type
    when 'flaky'
      random_error
    when 'fault'
      raise_error
    when 'slow'
      random_sleep
    end
  end
end
