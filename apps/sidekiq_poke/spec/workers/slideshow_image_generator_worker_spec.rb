# frozen_string_literal: true

require 'spec_helper'
require 'sidekiq/testing'
require 'rspec'
require 'webmock/rspec'
require_relative '../../lib/workers/slideshow_image_generator_worker'
require_relative '../../lib/services/slideshow_image_generator_service'

RSpec.describe SlideshowGeneratorWorker do
  let(:service) { SlideshowGeneratorService.new }
  let(:pokemon_name) { 'charmander' }
  let(:image_url) { 'https://pokeapi.co/media/sprites/pokemon/stub.png' }
  let(:payload) { { 'pokemon_name' => pokemon_name, 'behavior' => 'default' } }
  let(:payload_nonexistent) { { 'pokemon_name' => 'nonexistent', 'behavior' => 'default' } }

  before do
    allow(SlideshowGeneratorService).to receive(:new).and_return(service)
  end

  describe 'job enqueuing' do
    it 'enqueues a job' do
      expect do
        SlideshowGeneratorWorker.perform_async(pokemon_name)
      end.to change(SlideshowGeneratorWorker.jobs, :size).by(1)
    end
  end

  describe 'perform job' do
    it 'downloads and saves the image' do
      expect(service).to receive(:generate).with(pokemon_name).and_return(nil)

      Sidekiq::Testing.inline! do
        SlideshowGeneratorWorker.perform_async(payload)
      end
    end

    it 'raises an error if the Pokémon is not found' do
      expect(service).to receive(:generate).with('nonexistent').and_raise(StandardError)

      expect do
        Sidekiq::Testing.inline! do
          SlideshowGeneratorWorker.perform_async(payload_nonexistent)
        end
      end.to raise_error(StandardError)
    end
  end
end
