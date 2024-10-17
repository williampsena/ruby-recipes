# frozen_string_literal: true

require 'spec_helper'
require 'sidekiq/testing'
require 'rspec'
require 'webmock/rspec'
require_relative '../../lib/workers/creator_pokemon_worker'
require_relative '../../lib/services/creator_pokemon_service'

RSpec.describe CreatorPokemonWorker do
  let(:service) { CreatorPokemonService.new }
  let(:pokemon_name) { 'pikachu' }
  let(:payload) { { 'pokemon_names' => [pokemon_name] } }
  let(:next_payload) { { 'pokemon_name' => pokemon_name, 'behavior' => 'default' } }

  before do
    allow(CreatorPokemonService).to receive(:new).and_return(service)
  end

  describe 'job enqueuing' do
    it 'enqueues a job' do
      expect do
        CreatorPokemonWorker.perform_async(payload)
      end.to change(CreatorPokemonWorker.jobs, :size).by(1)
    end
  end

  describe 'perform' do
    before do
      allow(DownloadPokemonImageWorker).to receive(:perform_async).with(next_payload).and_return(nil)
      allow(SlideshowGeneratorWorker).to receive(:perform_async).with(next_payload).and_return(nil)
    end

    it 'when works' do
      expect(service).to receive(:create).with(pokemon_name).and_return(true)

      Sidekiq::Testing.inline! do
        CreatorPokemonWorker.perform_async(payload)
      end
    end
  end
end
