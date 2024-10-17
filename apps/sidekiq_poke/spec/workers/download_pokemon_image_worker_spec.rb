# frozen_string_literal: true

require 'spec_helper'
require 'sidekiq/testing'
require 'rspec'
require 'webmock/rspec'
require_relative '../../lib/workers/download_pokemon_image_worker'
require_relative '../../lib/services/download_pokemon_image_service'

RSpec.describe DownloadPokemonImageWorker do
  let(:service) { DownloadPokemonImageService.new }
  let(:pokemon_name) { 'squirtle' }
  let(:image_url) { 'https://pokeapi.co/media/sprites/pokemon/stub.png' }
  let(:payload) { { 'pokemon_name' => pokemon_name, 'behavior' => 'default' } }
  let(:payload_nonexistent) { { 'pokemon_name' => 'nonexistent', 'behavior' => 'default' } }

  before do
    allow(DownloadPokemonImageService).to receive(:new).and_return(service)
  end

  describe 'job enqueuing' do
    it 'enqueues a job' do
      expect do
        DownloadPokemonImageWorker.perform_async(payload)
      end.to change(DownloadPokemonImageWorker.jobs, :size).by(1)
    end
  end

  describe 'perform job' do
    it 'downloads and saves the image' do
      expect(service).to receive(:download_image).with(pokemon_name).and_return(image_url)

      Sidekiq::Testing.inline! do
        DownloadPokemonImageWorker.perform_async(payload)
      end
    end

    it 'raises an error if the Pokémon is not found' do
      expect(service).to receive(:download_image).with('nonexistent').and_raise(StandardError)

      expect do
        Sidekiq::Testing.inline! do
          DownloadPokemonImageWorker.perform_async(payload_nonexistent)
        end
      end.to raise_error(StandardError)
    end
  end
end
