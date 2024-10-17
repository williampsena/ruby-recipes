# frozen_string_literal: true

require 'sidekiq/testing'
require 'byebug'
require 'dotenv'

if ENV['ENV'] == 'test'
  Dotenv.load('.env.test')
else
  Dotenv.load('.env')
end

Sidekiq::Testing.fake!
