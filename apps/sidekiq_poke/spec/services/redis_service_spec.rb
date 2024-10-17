# frozen_string_literal: true

require 'spec_helper'
require 'rspec'
require_relative '../../lib/services/redis_service'

RSpec.describe RedisService do
  subject { described_class.new }

  describe 'set/2' do
    it 'when puts some value' do
      subject.set('foo', 'bar')
    end
  end

  describe 'get/2' do
    it 'when gets some value' do
      subject.set('bar', 'biz')
      expect(subject.get('bar')).to eq('biz')
    end
  end

  describe 'delete/1' do
    it 'when deletes some key' do
      subject.set('biz', 'foo')
      expect(subject.get('biz')).to eq('foo')
      subject.delete('biz')
      expect(subject.get('biz')).to eq(nil)
    end
  end
end
