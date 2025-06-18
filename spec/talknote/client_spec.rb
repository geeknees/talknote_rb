# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Talknote::Client do
  let(:client) { described_class.allocate }
  let(:mock_conn) { instance_double(Faraday::Connection) }
  let(:mock_response) { instance_double(Faraday::Response, status: 200, body: '{"result": "success"}') }

  before do
    # Initialize the client without calling the constructor
    client.instance_variable_set(:@conn, mock_conn)
    client.send(:define_singleton_method, :conn) { mock_conn }
  end

  describe '#dm_post' do
    it 'sends a POST request to the correct endpoint' do
      expect(mock_conn).to receive(:post).with('api/v1/dm/post/123').and_return(mock_response)

      result = client.dm_post('123', 'Hello World')
      expect(result).to eq({ 'result' => 'success' })
    end

    it 'includes options in the request body' do
      expect(mock_conn).to receive(:post).with('api/v1/dm/post/123') do |&block|
        req = double('request')
        expect(req).to receive(:headers=).with({ 'Content-Type' => 'application/json' })
        expect(req).to receive(:body=).with('{"body":"Hello","priority":"high"}')
        block.call(req)
        mock_response
      end

      client.dm_post('123', 'Hello', { priority: 'high' })
    end
  end

  describe '#dm_create' do
    it 'sends a POST request to create a new DM' do
      expect(mock_conn).to receive(:post).with('api/v1/dm/create').and_return(mock_response)

      result = client.dm_create('user123')
      expect(result).to eq({ 'result' => 'success' })
    end

    it 'includes initial message when provided' do
      expect(mock_conn).to receive(:post).with('api/v1/dm/create') do |&block|
        req = double('request')
        expect(req).to receive(:headers=).with({ 'Content-Type' => 'application/json' })
        expect(req).to receive(:body=).with('{"user_id":"user123","body":"Hello!"}')
        block.call(req)
        mock_response
      end

      client.dm_create('user123', 'Hello!')
    end
  end

  describe '#dm_search' do
    it 'sends a GET request with query parameters' do
      expect(mock_conn).to receive(:get).with('api/v1/dm/search', { q: 'test query' }).and_return(mock_response)

      result = client.dm_search('test query')
      expect(result).to eq({ 'result' => 'success' })
    end

    it 'includes additional options' do
      expect(mock_conn).to receive(:get).with('api/v1/dm/search', { q: 'test', limit: 10 }).and_return(mock_response)

      client.dm_search('test', { limit: 10 })
    end
  end

  describe '#dm_members' do
    it 'sends a GET request to the members endpoint' do
      expect(mock_conn).to receive(:get).with('api/v1/dm/members/123').and_return(mock_response)

      result = client.dm_members('123')
      expect(result).to eq({ 'result' => 'success' })
    end
  end

  describe '#dm_leave' do
    it 'sends a POST request to leave the conversation' do
      expect(mock_conn).to receive(:post).with('api/v1/dm/leave/123').and_return(mock_response)

      result = client.dm_leave('123')
      expect(result).to eq({ 'result' => 'success' })
    end
  end

  describe '#dm_mark_read' do
    it 'sends a POST request to mark as read' do
      expect(mock_conn).to receive(:post).with('api/v1/dm/read/123').and_return(mock_response)

      result = client.dm_mark_read('123')
      expect(result).to eq({ 'result' => 'success' })
    end

    it 'includes message_id when provided' do
      expect(mock_conn).to receive(:post).with('api/v1/dm/read/123') do |&block|
        req = double('request')
        expect(req).to receive(:headers=).with({ 'Content-Type' => 'application/json' })
        expect(req).to receive(:body=).with('{"message_id":"msg456"}')
        block.call(req)
        mock_response
      end

      client.dm_mark_read('123', 'msg456')
    end
  end

  describe 'error handling' do
    let(:error_response) { instance_double(Faraday::Response, status: 401, body: 'Unauthorized') }

    it 'raises Talknote::Error for 401 responses' do
      expect(mock_conn).to receive(:get).with('api/v1/dm').and_return(error_response)

      expect { client.dm }.to raise_error(Talknote::Error, 'Unauthorized: Please check your access token')
    end

    it 'raises Talknote::Error for 404 responses' do
      not_found_response = instance_double(Faraday::Response, status: 404, body: 'Not Found')
      expect(mock_conn).to receive(:get).with('api/v1/dm').and_return(not_found_response)

      expect { client.dm }.to raise_error(Talknote::Error, 'Not Found: Resource does not exist')
    end
  end
end
