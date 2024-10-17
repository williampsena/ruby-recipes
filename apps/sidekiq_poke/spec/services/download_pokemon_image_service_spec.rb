# frozen_string_literal: true

require 'spec_helper'
require 'rspec'
require 'webmock/rspec'
require_relative '../../lib/services/download_pokemon_image_service'

RSpec.describe DownloadPokemonImageService do
  subject { described_class.new }
  let(:pokemon_name) { 'pikachu' }
  let(:image_url) { 'https://pokeapi.co/media/sprites/pokemon/stub.png' }
  let(:json_payload) do
    {
      'sprites' => {
        'front_default' => image_url
      }
    }.to_json
  end

  let(:fake_image_content) { 'fake content' }
  let(:redis_service) { RedisService.new }

  before do
    allow(RedisService).to receive(:new).and_return(redis_service)

    stub_request(:get, image_url)
      .to_return(status: 200, body: fake_image_content)
  end

  describe 'download_image/1' do
    it 'downloads and saves the image' do
      expect(redis_service).to receive(:get).with('pikachu').and_return(json_payload)
      expect(redis_service).to receive(:set).with('pikachu::images', anything)
      expect(redis_service).to receive(:set).with('pikachu::front_default', anything)

      image_paths = subject.download_image(pokemon_name)
      image_paths.each do |image_path|
        expect(File.exist?(image_path)).to be_truthy

        expect(File.read(image_path)).to eq(fake_image_content)

        FileUtils.rm_f(image_path)
      end
    end

    it 'raises an error if the Pokémon is not found' do
      expect do
        subject.download_image('nonexistent')
      end.to raise_error(StandardError, /⛔ No pokemon \(nonexistent\) fount at database/)
    end
  end
end
