# frozen_string_literal: true

require 'spec_helper'
require 'rspec'
require 'webmock/rspec'
require_relative '../../lib/services/redis_service'
require_relative '../../lib/services/creator_pokemon_service'

RSpec.describe CreatorPokemonService do
  subject { described_class.new }
  let(:base_api_url) { CreatorPokemonService::BASE_API_URL }
  let(:pokemon_name) { 'pikachu' }
  let(:image_url) { 'https://pokeapi.co/media/sprites/pokemon/stub.png' }
  let(:pokeapi_response) do
    {
      'sprites' => {
        'front_default' => image_url
      }
    }.to_json
  end
  let(:redis_service) { RedisService.new }

  before do
    allow(RedisService).to receive(:new).and_return(redis_service)

    stub_request(:get, "#{base_api_url}/pokemon/#{pokemon_name.downcase}")
      .to_return(status: 200, body: pokeapi_response, headers: { 'Content-Type' => 'application/json' })
  end

  describe 'create/1' do
    it 'downloads and saves the data at database' do
      expect(redis_service).to receive(:get).with(pokemon_name).and_return(nil)

      data = subject.create(pokemon_name)

      expect(data).to eq(JSON.parse(pokeapi_response))
    end

    it 'raises an error if the Pokémon is not found' do
      stub_request(:get, "#{base_api_url}/pokemon/nonexistent")
        .to_return(status: 404)

      expect do
        subject.create('nonexistent')
      end.to raise_error(StandardError, /⛔ Failed to find Pokémon: nonexistent/)
    end
  end
end
