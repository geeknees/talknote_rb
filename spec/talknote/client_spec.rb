# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Talknote::Client do
  let(:mock_conn) { instance_double(Faraday::Connection) }
  let(:mock_response) { instance_double(Faraday::Response, status: 200, body: '{"result": "success"}') }
  let(:client) do
    client_instance = described_class.allocate
    client_instance.instance_variable_set(:@conn, mock_conn)
    client_instance
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
        expect(req).to receive(:headers).and_return({})
        expect(req).to receive(:headers=).with('Content-Type' => 'application/x-www-form-urlencoded')
        expect(req).to receive(:body=).with('message=Hello&priority=high')
        block.call(req)
        mock_response
      end

      client.dm_post('123', 'Hello', { priority: 'high' })
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

  describe '#group' do
    it 'fetches the group list' do
      expect(mock_conn).to receive(:get).with('api/v1/group').and_return(mock_response)

      result = client.group
      expect(result).to eq({ 'result' => 'success' })
    end
  end

  describe '#group_list' do
    it 'fetches messages from a specific group' do
      expect(mock_conn).to receive(:get).with('api/v1/group/list/123').and_return(mock_response)

      result = client.group_list('123')
      expect(result).to eq({ 'result' => 'success' })
    end
  end

  describe '#group_unread' do
    it 'fetches unread count for a specific group' do
      expect(mock_conn).to receive(:get).with('api/v1/group/unread/123').and_return(mock_response)

      result = client.group_unread('123')
      expect(result).to eq({ 'result' => 'success' })
    end
  end

  describe '#group_post' do
    it 'sends a POST request to post a message to a group' do
      expect(mock_conn).to receive(:post).with('api/v1/group/post/123').and_return(mock_response)

      result = client.group_post('123', 'Hello Group!')
      expect(result).to eq({ 'result' => 'success' })
    end

    it 'includes options in the request body' do
      expect(mock_conn).to receive(:post).with('api/v1/group/post/123') do |&block|
        req = double('request')
        expect(req).to receive(:headers=).with('Content-Type' => 'application/x-www-form-urlencoded')
        expect(req).to receive(:body=).with('message=Hello+Group%21&priority=high')
        block.call(req)
        mock_response
      end

      client.group_post('123', 'Hello Group!', { priority: 'high' })
    end
  end
end
