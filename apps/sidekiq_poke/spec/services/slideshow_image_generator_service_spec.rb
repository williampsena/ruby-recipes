# frozen_string_literal: true

require 'spec_helper'
require 'rspec'
require_relative '../../lib/services/slideshow_image_generator_service'

RSpec.describe SlideshowGeneratorService do
  subject { described_class.new }
  let(:pokemon_name) { 'pikachu' }
  let(:images) do
    [
      './fixtures/images/poke_images/bulbasaur.png',
      './fixtures/images/poke_images/charmander.png',
      './fixtures/images/poke_images/pikachu.png',
      './fixtures/images/poke_images/squirtle.png'
    ].map { |i| File.expand_path(i) }
  end
  let(:redis_service) { RedisService.new }

  before do
    allow(RedisService).to receive(:new).and_return(redis_service)
  end

  describe 'generate/1' do
    it 'downloads and saves data to redis' do
      expect(redis_service).to receive(:get).with('pikachu::images').and_return(images.to_json)

      image_path = subject.generate(pokemon_name)

      expect(File.exist?(image_path)).to be_truthy

      FileUtils.rm_f(image_path)
    end
  end
end
